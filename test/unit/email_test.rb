require 'test_helper'

class EmailTest < ActiveSupport::TestCase

  test "sending test email to self should work" do
    mail_template = MailTemplate.find_by_year(2012)
    Timecop.freeze(1.hour.ago) do
      assert_difference ->{ActionMailer::Base.deliveries.count} do
        Email.send_test_email(2012, 'test@example.com')
      end
      assert_equal Time.now.to_s, mail_template.reload.test_mail_sent_at.to_s
    end
    assert mail_template.test_mail_sent?, 'One hour later this should be true'
  end

  test "sending out all mails should work" do
    skip "we need a mocking library to avoid all this hard work"
  end
end
