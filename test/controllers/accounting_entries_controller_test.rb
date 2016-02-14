require 'test_helper'

class AccountingEntriesControllerTest < ActionController::TestCase
  setup do
    @contract = Contract.last
    @accounting_entry = @contract.accounting_entries.last
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_entries)
  end

  test "should get new" do
    get :new, contract_id: @contract.id
    assert_response :success
  end

  test "should create accounting_entry" do
    assert_difference(->{AccountingEntry.count}) do
      post :create, contract_id: @contract.id, accounting_entry: { amount: 100.0, date: Date.current }
    end

    assert_redirected_to accounting_entry_path(assigns(:accounting_entry))
  end

  test "should show accounting_entry" do
    get :show, id: @accounting_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @accounting_entry
    assert_response :success
  end

  test "should update accounting_entry" do
    patch :update, id: @accounting_entry, contract_id: @contract.id,
          accounting_entry: { amount: 3000.0, date: Date.current }
    assert_redirected_to accounting_entry_path(assigns(:accounting_entry))
  end

  test "should destroy accounting_entry" do
    assert_difference('AccountingEntry.count', -1) do
      delete :destroy, id: @accounting_entry
    end

    assert_redirected_to accounting_entries_path
  end
end
