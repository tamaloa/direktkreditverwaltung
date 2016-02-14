

- Company anlegen
- Kontakt anlegen
- Kreditvertrag anlegen
- Geld buchen
- Jahresabschluss machen

- vor kündigen/auflösen eines Vetrages müssen jeweilige Jahresabschlüsse gemacht sein



# Todo

## import
* bereits gekündigte Verträge mit aufnehmen
* kunet eV mit in contacts und contracts aufnehmen?
* contact adressen

## sonstiges
- db/seeds.rb als template einchecken? bzw ist das überhaupt notwendig? -> da wir alle unterschoredlich Projekte haben wollen wir keine seeds.rb sondern eher die custom/text_snippets
- custom/text_snippets.yml versus db/seeds.rb - remove from git?

## felder in forms und Anzeigen sinnvoll sortieren
* http://localhost:3000/contracts/remaining_term: link zu Contract über nummer
* Befristung: Laufzeit / duration_month/year / enddate -> zeige immer nur Enddatum an (determine_befristung())
* Befristung vs. Unbefristung in Anzeige: finde sinnvolle Anzeige (nur eines von beiden oder mit Hinweis oder...)
* contract / contract-version view: only show fields if present: notice_period, end_date, duration_month, duration_year
* Auswertungen: sortieren nach namen
* contract/index: gekündigte Verträge -> check Anzeige des Kontostands

## eigenes Laufzeitfeld
* Problem contracts/_form -> end_date: wenn einmal Datum ausgewählt wurde kanns nicht mehr null gesetzt werden -> blank versus default problem!

## validations verbessern
* contract create/update: 
** eines der Befristungsfelder sollte gesetzt sein
** number muss gesetzt sein und unique

* contract_versions/form: number should be prefilled and unique!

## act_act
Berechnung: Verzinsung nach tatsächlicher Anzahl Tage (365 / 366 Schaltjahr), keine Verzinsung erster Tag

* interest_days fix
* check day_left_in_year

## contract_terminators: was ist das? wie funktionierts? warum?
* ACHTUNG: bei Kündigung eines Vertrages wird automatisch auf Jahresabschluss gemacht?!


## contracts/remaining_term
* fix sort of contracts in contract.all_with_remaining_month() (currently no sort due to extension for unbefristete contracts)

## backup sqlite3 db

## Test
* clean up db after rake test (currently cucumber fails when rake test was ran before)