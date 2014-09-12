require 'test_helper'

class YearEndClosingsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create year_end_closing" do
    expected_accounting_entries = Contract.where(:add_interest_to_deposit_annually => true).count
    assert_difference(->{AccountingEntry.count}, expected_accounting_entries) do
      post :create, date: {year: 2013}
    end

    assert_redirected_to new_year_end_closing_path
  end

end
