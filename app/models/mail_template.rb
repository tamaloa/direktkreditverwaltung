class MailTemplate < ActiveRecord::Base

  validates_uniqueness_of :year
  validates_presence_of :year

  after_initialize :set_defaults


  def set_defaults
    self.subject ||= "Kontomitteilung Direktkredit Zolle GmbH #{year}"
    self.content ||= "Hallo @geber_in@,

wir haben unseren Jahresabschluss gemacht und die Zinsberechnungen deines Kredits abgeschlossen. Anbei senden wir dir den aktuellen Kontoauszug als PDF, wenn du diesen auf dem Postweg benötigst, kannst du uns ein kurzes Feedback geben.

Im Newsletter findest du alle Neuigkeiten aus #{year}.

Bei Frage o.ä. kannst du dich gerne bei uns melden.

Liebe Grüße"
  end

  def test_mail_sent?
    test_mail_sent_at && test_mail_sent_at <= 1.hour.ago
  end

  def update_newsletter_file(file)
    return true unless file
    self.filename = File.basename(file.original_filename)
    self.content_type = file.content_type
    self.file_content = file.read
    self.save
  end

end
