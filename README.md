
# Direktkreditverwaltung
[![Build Status](https://travis-ci.org/tamaloa/direktkreditverwaltung.svg?branch=master)](https://travis-ci.org/tamaloa/direktkreditverwaltung)
[![Code Climate](https://codeclimate.com/github/tamaloa/direktkreditverwaltung/badges/gpa.svg)](https://codeclimate.com/github/tamaloa/direktkreditverwaltung)

Nach Erfordernissen eines Mietshäuser Syndikat Projekts.

Dies ist der "Leipziger" Fork der Direktkreditverwaltung. Die ursprüngliche "Berliner" version wurde scheinbar durch ein python projekt abgelöst. 
Ausgehend von diesem Fork gibt es einen in eine andere Richtung entwickelten ["Dresdner" Fork](https://github.com/pamuche/direktkreditverwaltung).

## Einführung

Diese Rails App erlaubt es auf einfache Art und Weise die im Syndikat üblichen Direktkredite zu verwalten. Ziel ist es
die jährlich erfolgende Zinsberechnung Fehlerfrei durch zu führen und das versenden der Kontoauszüge per Post oder E-Mail
zu vereinfachen.

Die Zinsberechnung wird nach der allgemein in MS-Excel (bzw. OpenOffice Calc) üblichen DAYS360 methode, die auch bisher im
  Syndikat angewandt wird, durchgeführt. Weitere Informationen zu verschiedenen Möglichkeiten der Zinsberechnungen in
  [wikipedia](http://de.wikipedia.org/wiki/Zinssatz#Berechnungsmethoden) und in der [Readme des days360 gems](https://github.com/tamaloa/days360)

#### Verwaltung

Verwaltet:

* Kontaktdaten
* Verträge
* Versionen von Verträgen (Laufzeiten und Zinssatz kann sich ändern)
* Buchungen

#### Funktionen

* Kontoauszüge als PDF
* Jahresabschluss (die Zinsen eines Jahres auf Konto gutschreiben)
* Vertrag auflösen (zum Stichtag den Auszahlungsbetrag inkl. Zinsen berechnen)
* Versenden von Kontoauszügen mit zusätzlichem Anhang via E-Mail
* Analysen
** Vertragsübersicht nach Auslaufdatum
** Durchschnittliche Zinssätze


#### Import

Import von:

* Kontakten 
    * `$ rake import:contacts[/path/to/csv_file.csv]`
* Direktkreditverträgen
    * `$ rake import:contracts[/path/to/csv_file.csv]`
    * Kontakte und DK-Verträge werden verlinkt wenn den DK-Verträgen Namen zugeordnet sind
* Buchungseinträgen möglich
    * `$ rake import:accounting_entries[/path/to/csv_file.csv]`

(benötigtes Format der csv-Dateien ist in lib/tasks/import.rake beschrieben)




## Development

### Prerequisits

* postgres (install e.g. on osx via homebrew: `$ brew install postgresql`; linux `apt-get install postgresql libpq-dev`)
* you may want to use rvm (https://rvm.io) to manage your ruby versions and gemset

### Installation

1. git clone repo and cd into repo
2. check ruby version and gemset you want to use, e.g. 
  - create and edit `.ruby-version` and `.ruby-gemset` 
  - `$ cd .`
3. `$ gem install bundler`
4. `$ bundle install` (you may `$ bundle update` to avoid problems installing `libv8`)

5. create database config, e.g. `$ cp config/database.yml_template_<db_of_your_choice> config/database.yml` and edit according to your needs
6. setup db: `$ rake db:setup`
7. migrate db: `$ rake db:migrate`

8. start the app: `$ rails server` -> the app is now available on http://localhost:3000

9. optional: `$ cp config/settings.yml_template config/settings.yml` and edit according to your needs

10. optional: `$ rake db:seed` to load minimal default content into db or

11. optional: `$ rake db:fixtures:load` to load the test dataset used in unit tests

### Tests

1. `$ rake db:migrate`
2. `$ rake db:test:prepare`
3. `$ cucumber`
4. `$ rake test`

