require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create contact" do
    assert_difference(->{Contact.count}) do
      post :create, contact: { name: 'Nachname', prename: 'Vorname', address: 'Bla\nblubb', email: 'test@example.com',
                                phone: '230323 23', account_number: '234234', bank_number: '2323', bank_name: 'Bankg Ba',
                                remark: 'Etwas das wir uns merken wollen'}
    end

    assert_response :redirect
  end

end
