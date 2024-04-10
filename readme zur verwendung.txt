Dieser Quellcode-Ordner enthält den Code für eine App, die als ToDo-Liste verwendbar ist. 
Folgen Sie den untenstehenden Anweisungen, um die App auszuführen.
Vorausgesetzt ist die vollständig funktionierende Installation von Flutter auf dem Computer.

Installation

    Laden Sie den Ordner als Zip-Datei herunter und entpacken Sie ihn in einem beliebigen Ordner auf Ihrem Computer.

Ausführen der App mit dem Terminal:
	Öffnen des Terminals und mit "cd" den richtigen Projektpfad angeben
	"flutter pub get" eingeben
	"flutter run" eingeben
	Ausführungsweise wählen z.B.: "2" --> Chrome Fenster wird geöffnet mit der Applikation darin (kann zwei Minuten dauern)
	nächster Schritt: Verwendung der App

Ausführen der App in Visual Studio Code:
	Öffnen Sie den entpackten Ordner in VSC.
	Rechts unten "run 'pub get' drücken, um Packages runterzuladen / "flutter pub get" im VSC. Terminal eingeben
	"Run and Debug" Menü 
	rechts unten "Chrome" oder angeschlossenes Android Smartphone (im Entwicklermodus) auswählen 
	"Run and Debug" auswählen 
	(falls angezeigt: "Dart & Flutter" auswählen)  
	--> App wird gestartet
	nächster Schritt: Verwendung der App

Ausführen der App in Android Studio:
	Öffnen Sie AS.
	"open"
	Passenden Ordner auswählen
	trust project
	Unten/oben: "pub get" für Dependencies und Packages wählen
	Oben bei "Devices" Chrome / angeschlossenes Android Smartphone (im Entwicklermodus) / Emuliertes Smartphone (starten und auswählen) auswählen 
	Falls noch nicht ausgewählt: /lib/main.dart 
	Playbutton "run main.dart" / Käfer-Button "debug main.dart"
	nächster Schritt: Verwendung der App


Verwendung der App

    Auf der Startseite der App können Sie Ihre Aufgabenliste sehen.
    Klicken Sie auf die Schaltfläche Neue Aufgabe hinzufügen, um eine neue Aufgabe hinzuzufügen.
    Geben Sie einen Titel und eine Beschreibung für die Aufgabe ein und klicken Sie auf die Schaltfläche Speichern, um die Aufgabe zu speichern.
    Klicken Sie auf die Schaltfläche Erledigt, um eine Aufgabe als erledigt zu markieren.
    Klicken Sie auf das Todo, um den Titel und die Beschreibung einer Aufgabe zu bearbeiten.
    Klicken Sie auf die Checkbox, um das Todo als Erledigt zu markieren
    Klicken Sie auf den Löschen-Knopf, um eine Aufgabe zu löschen.
    Klicken Sie auf den Theme-Knopf oben rechts, um die Farben der App zu wechseln.