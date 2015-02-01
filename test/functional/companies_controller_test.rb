require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  setup do
    @company = Company.find(1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end



  test "should create company" do
    assert_difference('Company.count') do
      post :create, company: { bank_account_info: @company.bank_account_info, bank_name: @company.bank_name, city: @company.city, email: @company.email, gmbh_executive_board: @company.gmbh_executive_board, gmbh_name: @company.gmbh_name, gmbh_register_number: @company.gmbh_register_number, gmbh_tax_number: @company.gmbh_tax_number, name: @company.name, street: @company.street, verein_name: @company.verein_name, web: @company.web, zip_code: @company.zip_code }
    end

    assert_redirected_to company_path(assigns(:company))
  end

  test "should show company" do
    get :show, id: @company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company
    assert_response :success
  end

  test "should update company" do
    put :update, id: @company, company: { bank_account_info: @company.bank_account_info, bank_name: @company.bank_name, city: @company.city, email: @company.email, gmbh_executive_board: @company.gmbh_executive_board, gmbh_name: @company.gmbh_name, gmbh_register_number: @company.gmbh_register_number, gmbh_tax_number: @company.gmbh_tax_number, name: @company.name, street: @company.street, verein_name: @company.verein_name, web: @company.web, zip_code: @company.zip_code }
    assert_redirected_to company_path(assigns(:company))
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete :destroy, id: @company
    end

    assert_redirected_to companies_path
  end
end
