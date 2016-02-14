class MailTemplate < ActiveRecord::Base
  #TODO:Strong Params attr_accessible :content, :footer, :subject, :year, :newsletter
  has_attached_file :newsletter

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

end
