require 'test_helper'

class YearEndClosingsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create year_end_closing" do
    assert_difference('AccountingEntry.count') do
      post :create, date: {year: 2013}
    end

    assert_redirected_to new_year_end_closings_path
  end

end
