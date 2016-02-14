require 'test_helper'

class MailTemplatesControllerTest < ActionController::TestCase
  setup do
    @mail_template = MailTemplate.first
  end

  test "should get edit" do
    get :edit, id: @mail_template
    assert_response :success
  end

  test "should update mail_template" do
    put :update, id: @mail_template, mail_template: { content: @mail_template.content, footer: @mail_template.footer, subject: @mail_template.subject }
    assert_redirected_to emails_path(year: @mail_template.year)
  end

end
