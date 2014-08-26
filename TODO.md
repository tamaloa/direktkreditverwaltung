# BUG

# Für nächsten Jahresabschluss
* DKs Jahresabschluss PDFs einzeln abrufbar machen mit Person im Filename
* DKs Jahresabschluss PDFs gesammelt in zip downloadbar
* Vorlage für E-Mail erstellen
* Upload für Zollepost zu Vorlage ermöglichen
* Massen-Emailing ermöglichen (vorher Test-Mail an eigene Adresse, 12h Sperre).

# Kleinigkeiten

# Features
* Neue Zinsberechnung (Intervallbasiert) durchgehend nutzen
* Datenimport im UI anbieten mit Feedback was nicht passt
* Datenexport im UI anbieten (csv tabelle mit zusammengefassten daten)
* Jahresabschluss Zusammenfassungs PDF - möglichst klein mit allen wichtigen Daten um ausgedruckt in die Buchhaltung abgeheftet zu werden
* Authentication&Authorization inklusive Infos wer wann was verändert hat (wichtig falls es mal Probleme gibt) -> papertrail gem

# UI
* Durchgängig deutsche formate nutzen (, statt . für währungseingaben)
* js-forms (datepicker, % + € format unterstützung etc.)

# DONE
* bessere Intervallbasierte Zinsberechnung
* Klären warum die DKs mit sich verändernden Zinssätzen nicht richtig berechnet werden!
* Direktkredit zu einem Zeitpunkt kündigen
* Direktkreditliste mit mehr Infos (Addresse + Email der Person)
* Gekündigte DKs seperat und nur kurz anzeigen
* Ansicht Direktkredit mit allen Informationen (Versionen, Buchungen)
* Einzahlungen am 1.1. wurden scheinbar ignoriert. In Wahrheit war die Anzeige des Saldos falsch (Saldo enthielt 1.1. Einzahlung)
