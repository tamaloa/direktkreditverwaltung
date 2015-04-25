require 'test_helper'

class EmailTest < ActiveSupport::TestCase

  test "sending test email to self should work" do
    assert_difference ->{ActionMailer::Base.deliveries.count} do
      Email.send_test_email(2012, 'test@example.com')
    end
  end

  test "sending out all mails should work" do
    pending "we need a mocking library to avoid all this hard work"
  end
end
