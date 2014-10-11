require 'test_helper'

class YearClosingStatementsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, {id: Contract.first.id, year: 2013}
    assert_response :success
  end

end
