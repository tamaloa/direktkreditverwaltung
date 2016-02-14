require 'test_helper'

class EmailsControllerTest < ActionController::TestCase
  setup do
    @year = Date.current.year
    @email = Email.create!(contact: Contact.first, year: @year, mail_template: MailTemplate.find_or_create_by(year: @year))
  end

  test "should get index" do
    get :index, year: @email.year
    assert_response :success
  end

  test "should show email" do
    get :show, id: @email
    assert_response :success
  end

end
