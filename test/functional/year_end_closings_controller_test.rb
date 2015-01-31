require 'test_helper'

class YearEndClosingsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create year_end_closing" do
    expected_accounting_entries = Contract.where(:add_interest_to_deposit_annually => true).count
    assert_difference(->{AccountingEntry.count}, expected_accounting_entries) do
      post :create, date: {year: 2013}
    end

    assert_redirected_to year_end_closings_path
  end

  test "should show year_end_closing details" do
    get :show, id: 2012

    assert_response :success
  end

  test "should download year_end_closing as ZIP file" do
    get :show, id: 2012, format: :zip

    assert_response :success
  end

  test "should revert year_end_closings" do
    pending "We are not sure reverting year end closings should be allowed"
    expected_accounting_entries = Contract.where(:add_interest_to_deposit_annually => true).count
    # assert_difference(->{AccountingEntry.count}, expected_accounting_entries) do
    #   post :delete, id: 2012
    # end
    #
    # assert_response :success
  end

end
