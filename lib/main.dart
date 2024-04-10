import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert';


void main() {
  //Initialisiere die Widgets-Bindung
  initializeFlutterBinding();
  runApp(const MyApp());
}

void initializeFlutterBinding() async {
  WidgetsFlutterBinding.ensureInitialized(); //Initialisiere die Widgets-Bindung
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  final String title = 'To Do List to Go';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late ThemeData _theme; //Zeige an, welches Theme gerade an ist
  bool _isDarkMode = false; //Zeige an, ob das Theme gerade dunkel ist


  @override
  void initState() {
    super.initState();
    _loadThemeFromPreferences(); //Theme aus gespeicherten Einstellungen laden
  }

  //lade das Theme
  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    }); //Das aktuelle Theme wird basierend auf dem Wert von _isDarkMode auf das dunkle oder helle Thema festgelegt.
  }

  //toggle das Theme
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode; //Der Wert von _isDarkMode wird umgekehrt
      _theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(
        title: 'To Do List To Go',
        toggleTheme: _toggleTheme,
      ),
    );
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.toggleTheme})
      : super(key: key);

  final String title;
  final Function() toggleTheme;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> _todos = []; //Liste-Datenstruktur aus Objekten der Klasse "TodoItem"

  //behandeln user input aus Textfeldern
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  String _newTodoTitle = ''; //zur Validierung der Korrektheit


  //bei Programmstart seine Daten laden
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //Aufruf beim Zerstören eines State Objekts
  @override
  void dispose() {
    //_textEditingController.dispose(); //Ressourcen freigeben
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // Speichern der Todo-Liste im Speicher
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance(); //SharedPreferences-Instanz erhalten
    final data = _todos.map((todo) => todo.toJson()).toList(); //Daten in eine Liste von Json-Objekten umwandeln
    await prefs.setString('todoList', json.encode(data)); //mit dem key 'todoList' als codierten String speichern
  }

  // Laden der Todo-Liste aus dem Speicher
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todoList'); //Daten mit dem Schlüssel 'todoList' erhalten
    if (data != null) { //prüfen, ob Daten vorhanden sind
      final jsonData = json.decode(data) as List; //Daten decodieren und in eine Liste umwandeln
      setState(() { //Todo-Items aus den Json-Daten erstellen und der Liste zuweisen
        _todos = jsonData.map((todo) => TodoItem.fromJson(todo)).toList();
      });
    }
  }

  //Hinzufuegen eines Todos zur Liste
  void _addTodoItem(TodoItem todo) {
    setState(() {
      _todos.add(todo); //Objekt zur Liste hinzufügen
    });
    _saveData();  //Daten sichern
  }

  //Löschen eines Todos aus der Liste
  void _removeTodoItem(int index) {
    showDialog( //zeigt einen Dialog auf dem Bildschirm
      context: context,
      builder: (BuildContext context) { //Builder, der den Inhalt des Dialogs definiert
        return AlertDialog( 
          title: const Text("Löschen bestätigen"),
          content: const Text("Möchten Sie dieses Todo löschen?"),
          actions: <Widget>[ //die zwei Knöpfe des Dialogs
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop(); //Dialog wird geschlossen
              },
            ),
            TextButton(
              child: const Text("Löschen"),
              onPressed: () {
                setState(() {
                  _todos.removeAt(index); //Löschen des Eintrags aus der Liste
                });
                Navigator.of(context).pop(); //Dialog wird geschlossen
                _saveData(); // speichere aktualisierte Liste in sharedPreferences
              },
            ),
          ],
        );
      },
    );
  }



  // Editierungsfunktion einer Todo-Karte mit Fehlerprüfung
  Widget _buildEditTodoCard(TodoItem todo) {
    // Initialisiert zwei Text-Controller mit den Titel- und Beschreibungs-Texten des gegebenen Todo-Objekts
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    final dueDateController = TextEditingController(text: todo.dueDate);

    return AlertDialog(
      title: const Text('Ändere das Todo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'Ändere hier den Titel',
              ),
              maxLength: 70, // Maximale Länge der Eingabe auf 70 Zeichen begrenzen
            ),
            const SizedBox(height: 9),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
                hintText: 'Ändere hier die Beschreibung',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Beendigungsdatum (optional)',
                hintText: 'In dem Format "tt.mm"',
              ),
            ),

          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            // Liest die Texte aus den Controllern und entfernt Leerzeichen am Anfang und Ende
            final newTitle = titleController.text.trim();
            final newDesc = descriptionController.text.trim();
            final dueDate = dueDateController.text.trim();

            // Wenn der Titel leer ist, wird ein Fehler-AlertDialog angezeigt
            if (newTitle.isEmpty) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Fehler'),
                  content: const Text('Der Titel darf nicht leer sein.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (dueDate.isNotEmpty && !isValidDate(dueDate)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Fehler'),
                  content: const Text('Das eingegebene Datum ist ungültig. Bitte verwenden Sie das Format "tt.mm".'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );

            } else { // Andernfalls werden Titel und Beschreibung des Todo-Objekts aktualisiert und die Änderungen gespeichert
              setState(() {
                todo.title = newTitle;
                todo.description = newDesc;
                todo.dueDate = dueDateController.text;
              });
              _saveData();
              Navigator.of(context).pop();
            }
          },
          child: const Text('Sichern'),
        ),
      ],
    );
  }

  //Funktion erstellt Karte mit der man ein neues Todo erstellen kann
  Widget _buildAddTodoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 35.0),

            const Text(
              'Neue Todo Aufgabe',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 22.0),

            TextField(
              controller: _titleController,
              onChanged: (value) => setState(() => _newTodoTitle = value), //aktualisiert die Variable mit dem Titel
              decoration: const InputDecoration(
                labelText: "Titel",
                hintText: 'Der Titel der Aufgabe',
              ),
              maxLength: 70, // Maximale Länge der Eingabe auf 70 Zeichen begrenzen
            ),

            const SizedBox(height: 17.0),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Beschreibung (optional)",
                hintText: 'Die Beschreibung der Aufgabe',
              ),
            ),

            const SizedBox(height: 32.0),

            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(
                labelText: "Beendigungsdatum (optional)",
                hintText: 'Verwenden Sie das Format "tt.mm"',
              ),
            ),

            const SizedBox(height: 45.0),

            Row (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton( //Abbrechen Knopf
                  style: TextButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    //backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton( //Todo Hinzufügen Knopf
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    //backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _validateAndSaveTodo();
                  },
                  child: const Text(
                    'Hinzufügen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Todoitem anzeigen
  Widget _buildTodoItem(TodoItem todo, int index) {
    return Card(
      child: ListTile(
        onTap: () { // Wenn das Todo-Item geklickt wird, wird eine Dialog-Box angezeigt, die das Bearbeiten des Items ermöglicht
          showDialog(
            context: context,
            builder: (context) => _buildEditTodoCard(todo),
          );
        },
        leading: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _removeTodoItem(index), //Methode zum Löschen des Items
        ),
        
        title: Text(todo.title,  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    decoration: _todos[index].isDone
                        ? TextDecoration.lineThrough //wenn es erledigt ist, wird der Text durchgestrichen
                        : TextDecoration.none,
                  ),
        ),

        subtitle: Column( // Spalte, die Datum und Beschreibung enthält
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.description,  
              style: TextStyle(
                    fontSize: 16.0,
                    decoration: _todos[index].isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
            ),
            Text(
              todo.dueDate == "" ? "" : "Bis zum: ${todo.dueDate}", //falls Datum leer ist, zeige nichts an
              style: TextStyle(
                  fontSize: 16.0,
                  decoration: _todos[index].isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
          ],
        ),

        trailing: 
              Checkbox( // Todo wurde erledigt - Checkbox
                value: _todos[index].isDone,
                onChanged: (value) {
                  setState(() {
                    _todos[index].isDone = value ?? false;
                  });
                  _saveData();
                },
              ),
      ),
    );
  }

  // Methode zum Überprüfen beim Erstellen eines neuen Todos
  void _validateAndSaveTodo() {
    final dueDate = _dueDateController.text;

    setState(() {
      _newTodoTitle = _titleController.text.trim(); // Setze den Wert von _newTodoTitle auf den getrimmten Text
    });

    if (_newTodoTitle.isEmpty) { // Überprüfe, ob der neue Todo-Titel leer ist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fehler'),
          content: const Text('Der Titel darf nicht leer sein.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (dueDate.isNotEmpty && !isValidDate(dueDate)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fehler'),
          content: const Text('Das eingegebene Datum ist ungültig. Bitte verwenden Sie das Format "tt.mm".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else { // Wenn der Titel nicht leer ist, erstelle eine neue Todo-Instanz
      final description = _descriptionController.text;
      final dueDate = _dueDateController.text;

      final todo = TodoItem(title: _newTodoTitle, description: description, dueDate: dueDate);
      _addTodoItem(todo); // Füge das Todo der Todo-Liste hinzu
      _titleController.clear(); //Textfeld zurücksetzen
      _descriptionController.clear();
      _dueDateController.clear();
      Navigator.of(context).pop();
    }
  }

  //Datums Validierungsfunktion für das Format "dd.mm"
  bool isValidDate(String input) {
    final format = RegExp(r'^\d{2}\.\d{2}$');
    if (!format.hasMatch(input)) return false;
    final parts = input.split('.');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (day == null || month == null) return false;
    if (day < 1 || day > 31 || month < 1 || month > 12) return false;
    return true;
  }


  @override
  Widget build(BuildContext context) { // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.invert_colors),
            onPressed: widget.toggleTheme, // Zugriff auf state object von MyApp
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Hintergrundfarbe
      //wenn es keine Todos gibt, wird das angezeigt, ansonsten wird mit dem ListView.builder jedes einzelne Todo aufgelistet
      body: _todos.isEmpty ? // prüfe, ob die Todo-Liste leer ist
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Keine Todos vorhanden",
                style: TextStyle(fontSize: 19),
              ), 
            ],
          ),
        )
      :
        ListView.builder( //jedes einzele todoitem nacheinander erstellen und anzeigen
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            // return _buildTodoItem(_todos[index], index);
            return Padding(
              padding: EdgeInsets.only(bottom: index == _todos.length - 1 ? 80 : 0), //erhöht den Abstand nur für das letzte Todo-Item
              child: _buildTodoItem(_todos[index], index),
            );
          },
        ),

      floatingActionButton: SizedBox( //Hinzufügen Knopf
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _buildAddTodoCard(),
            );
          },
          //backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
      ),

    );
  }

}

//Klasse für Todo Aufgaben mit dem Titel und Wert ob es erledigt ist oder nicht
class TodoItem {
  String title;
  bool isDone;
  String description;
  String dueDate;

  //Konstruktor der Klasse: Titel(notNull), Erledigungsstatus(setzen oder false) 
  TodoItem({
    required this.title, this.isDone = false, required this.description, required this.dueDate
  });

  //gibt ein Map-Objekt zurück, das den Titel und den Status des To-Do-Eintrags enthält
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'description': description,
      'dueDate': dueDate
    };
  }

  //erzeugt ein neues Todoitem-Objekt aus einer gegeben JSON-Map
  factory TodoItem.fromJson(Map<String, dynamic> json) { //
     return TodoItem(
        title: json['title'] as String, // Extrahiert den Titelwert aus dem JSON-Objekt als String und weist ihn dem entsprechenden Attribut im TodoItem-Objekt zu.
        description: json['description'] as String,
        isDone: json['isDone'] as bool,
        dueDate: json['dueDate'] as String
     );  
  } // Im Gegensatz zum Standard-Konstruktor kann die Factory-Methode einen bereits erstellten Objekt-Cache zurückgeben,
  // eine Unterklasse erstellen oder ein Objekt zurückgeben, das nicht unbedingt eine Instanz der Klasse selbst ist.

}
