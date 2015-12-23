# Direktkreditverwaltung

Nach Erfordernissen eines Mietshäuser Syndikat Projekts.

## General

Zinsberechnung nach der "Deutschen Methode" 30/360 (mit der days360-Methode nach "The European Method (30E/360)"). Siehe http://de.wikipedia.org/wiki/Zinssatz#Berechnungsmethoden und http://en.wikipedia.org/wiki/360-day_calendar.

Die Berechnungsmethode kann durch Editieren von `config/settings.yml` auf `act_act` geändert werden. (Note: Currently not implemented!)

#### Verwaltung

Verwaltet:

* Kontaktdaten
* Verträge
* Versionen von Verträgen (Laufzeiten und Zinssatz kann sich ändern)
* Buchungen

#### Funktionen

* Kontoauszüge
* Zinsberechnungen
* Vertragsübersicht nach Auslaufdatum
* Jahresabschluss (die Zinsen eines Jahres auf Konto gutschreiben)
* Vertrag auflösen (zum Stichtag den Auszahlungsbetrag inkl. Zinsen berechnen)

#### Imports

Import von:

* Kontakten 
    * `$ rake import:contacts[/path/to/csv_file.csv]`
* Direktkreditverträgen
    * `$ rake import:contracts[/path/to/csv_file.csv]`
    * Kontakte und DK-Verträge werden verlinkt wenn den DK-Verträgen Namen zugeordnet sind
* Buchungseinträgen möglich
    * `$ rake import:accounting_entries[/path/to/csv_file.csv]`

(benötigtes Format der csv-Dateien ist in lib/tasks/import.rake beschrieben)

#### pdf-Ausgabe

* ist verfügbar für die Zinsübersicht, Zinsbriefe und Dankesbriefe
* kann mit Bildern und Textsnippets im Verzeichnis custom angepasst werden
* die &lt;Dateiname&gt;_template-Vorlagen in diesem Verzeichnis müssen in eine Datei &lt;Dateiname&gt; kopiert werden und dann editiert.

#### latex-Ausgabe

* z.B. die Zinsauswertung lässt sich im latex-Format ausgeben. Diese kann dann gespeichert, modifiziert und mit latex, dvipdfm, ... weiter verarbeitet werden
* die latex-Ausgabe ist der pdf-Ausgabe vorzuziehen, wenn die Möglichkeit der latex-Datei-Manipulation vor der pdf-Erstellung nötig ist
* Templates für die Zinsbriefe befinden sich in /app/views/layouts und /app/views/contracts . Sie enden auf "_template". Kopiere die _template-Dateien in Dateien mit gleichem Namen jedoch ohne "_template" und ändere die die Dateien wo nötig.
* Parameter für dvipdfm: -p a4 (Papiergröße), -l (Landscape mode für Dankesbriefe) 

## Configuration

* The type of contract number is `integer` by default. If you need it to be a `string` (e.g. like '2-06-001') edit `config/settings.yml` accordingly:
```
contract_number_type: "string" # one of: "string" | "integer", defaults to integer
```

## Geplant sind 

* Graphen

## Bekannte Fehler

* Löschen von Verträgen sollte Vertragsversionen, Buchungen, ... mitlöschen

## Development

### Installation

1. git clone repo and cd into repo
2. check ruby version and gemset you want to use, e.g. 
  - create and edit `.ruby-version` and `.ruby-gemset` 
  - `$ cd .`
3. `$ gem install bundler`
4. `$ bundle install` (you may `$ bundle update` to avoid problems installing `libv8`)

5. `$ cp config/database.example.yml config/database.yml` and edit according to your needs
6. migrate db: `$ rake db:migrate`

7. start the app: `$ rails server` -> the app is now available on http://localhost:3000

8. optional: `$ cp config/settings.yml_template config/settings.yml` and edit according to your needs


#### Prerequisits

* postgres (install e.g. on osx via homebrew: `$ brew install postgresql`)
* you may want to use rvm (https://rvm.io) to manage your ruby versions and gemset

### Tests

1. `$ rake db:migrate`
2. `$ rake db:test:prepare`
3. `$ cucumber`

### API docs

* create via: `$ rake doc:app`







