require 'test_helper'

class YearClosingStatementsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, {id: Contract.first.id, year: 2013}
    assert_response :success
  end

  test "should get pdf" do
    get :show, {id: Contract.first.id, year: 2013, format: :pdf}
    assert_response :success
  end

end
