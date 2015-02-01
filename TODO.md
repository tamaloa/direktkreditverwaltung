# BUG

# Für nächsten Jahresabschluss
* Vorlage für E-Mail erstellen
* Upload für Zollepost zu Vorlage ermöglichen
* Massen-Emailing ermöglichen (vorher Test-Mail an eigene Adresse, 12h Sperre).

# Kleinigkeiten
* Zinsen nur auf Verträge aufschlagen die noch keine Zinsen haben (oder wie geht man mit Verträgen um die schon
gekündigt sind aber wieder YearEndClosing mässig reverted wurden?
* Booker Model mit deposit, payback, year_closing methoden
* Movement Model in dem die Werte sinnvoll abrufbar sind (inkl. to_s -> € etc.?)

# Features
* Datenimport im UI anbieten mit Feedback was nicht passt
* Datenexport im UI anbieten (csv tabelle mit zusammengefassten daten)
* Jahresabschluss Zusammenfassungs PDF - möglichst klein mit allen wichtigen Daten um ausgedruckt in die Buchhaltung abgeheftet zu werden
* Authentication&Authorization inklusive Infos wer wann was verändert hat (wichtig falls es mal Probleme gibt) -> papertrail gem
* Jahresabschluss Übersicht als CSV/PDF runterladbar machen (für Buchhaltung)
* Mehrere Projekte verwalten können
** company model dass die Stammdaten hält erstellen
** alles mit company model scopen (belongs_to :company)
** User model mit login

# UI
* Durchgängig deutsche formate nutzen (, statt . für währungseingaben)
* js-forms (datepicker, % + € format unterstützung etc.)

# DONE
* BUG: Wenn DK-Vertrag ausversehen später startet kann man buchungen erstellen. Wenn dann Zinsauswertung dann 0% zinsen. Fixed.
* Neue Zinsberechnung (Intervallbasiert) durchgehend nutzen
* bessere Intervallbasierte Zinsberechnung
* Klären warum die DKs mit sich verändernden Zinssätzen nicht richtig berechnet werden!
* Direktkredit zu einem Zeitpunkt kündigen
* Direktkreditliste mit mehr Infos (Addresse + Email der Person)
* Gekündigte DKs seperat und nur kurz anzeigen
* Ansicht Direktkredit mit allen Informationen (Versionen, Buchungen)
* Einzahlungen am 1.1. wurden scheinbar ignoriert. In Wahrheit war die Anzeige des Saldos falsch (Saldo enthielt 1.1. Einzahlung)
* Zinsberechnung in seperates Modell ausgelagert (erstmal ohne act_act)
* DKs Jahresabschluss PDFs einzeln abrufbar machen mit Person im Filename
** year_end_closings/2013?contract=13
** year_end_closings/2013?contract=13&format=pdf
** year_end_closings/2013 -> jahresabschluss übersicht
*** #DK | Vorjahressaldo | Kontobewegungen | Zinsen | Saldo Jahresabschluss
** year_end_closings/2013?format=zip -> pdfs als zip datei
* DKs Jahresabschluss PDFs gesammelt in zip downloadbar

# AUS EMAIL
Vertrag erstellen: Eingabeformat Zinsen angeben
Vertrag erstellen: Mindestlaufzeit fehlt und Laufzeitangabe unklar (wirkt so als wenn eines von beiden sein muss).

Buchung erstellen: Kurzinfo (Nummer, Rahmenbedingungen, bisherige Kontostand) zum DK-Vertrag anzeigen um Fehler zu vermeiden.

Buchung erstellen: Eingabe Datum optimieren
Buchung erstellen: Eingabeformat Betrag vorgeben

Auswertung: Zinsen: Voreinstellung nicht das aktuelle sonder das letzte Jahr?

ALLGEMEIN: Jede erstellung (Buchung, Vertrag) nochmal zusammenfassend anzeigen und "JA, wirklich so!"

Import: Keine leeren Personen erstellen (Name muss?)
Import: Fehlt: Direktkreditverträge (zuordnung zu Person über Name/Vorname) importieren

Daten-Modell: befristung und kündigungsfrist modellierunge nicht ganz klar (versionen haben duration_months, duration_years)
