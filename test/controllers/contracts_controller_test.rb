require 'test_helper'

class ContractsControllerTest < ActionController::TestCase
  setup do
    @contract = Contract.last
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contracts)
  end

  test "should get new" do
    get :new, contact_id: @contract.contact.id
    assert_response :success
  end

  test "should create contract" do
    assert_difference(->{Contract.count}) do
      assert_difference(->{ContractVersion.count}) do
        post :create, contact_id: @contract.contact.id,
             contract: { add_interest_to_deposit_annually: @contract.add_interest_to_deposit_annually,
                         category: @contract.category, comment: @contract.comment, number: 2323,
                         contract_versions_attributes: [ version: 3234, interest_rate: 0.01, start: Date.current ]}
      end
    end

    assert_redirected_to contract_path(assigns(:contract))
  end

  test "should show contract" do
    get :show, id: @contract
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contract
    assert_response :success
  end

  test "should update contract" do
    patch :update, id: @contract, contract: { add_interest_to_deposit_annually: @contract.add_interest_to_deposit_annually, category: @contract.category, comment: @contract.comment, number: @contract.number }
    assert_redirected_to contract_path(assigns(:contract))
  end

  test "should destroy contract" do
    assert_difference('Contract.count', -1) do
      delete :destroy, id: @contract
    end

    assert_redirected_to contracts_path
  end


  test "should get interest" do
    get :interest
    assert_response :success
  end

  test "should get interest as pdf" do
    get :interest, {output: 'pdf_interest_letter'}
    assert_response :success
  end

  test "should get overview as pdf" do
    get :interest, {output: 'pdf_overview'}
    assert_response :success
  end

  # test "should get thanks letter as pdf" do
  #   get :interest, {output: 'pdf_thanks_letter'}
  #   assert_response :success
  # end
end
