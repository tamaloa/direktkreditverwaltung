require 'test_helper'

class ContractsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get interest" do
    get :interest
    assert_response :success
  end

  test "should get interest as pdf" do
    get :interest, {output: 'pdf_interest_letter'}
    assert_response :success
  end

  test "should get interest as latex" do
    get :interest, {output: 'pdf_interest_letter'}
    assert_response :success
  end

end
