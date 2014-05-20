require 'test_helper'

class ContractTerminatorTest < ActiveSupport::TestCase

  def setup
    @running_contract = Contract.first
  end


  test "contract terminator should terminate a contract" do
    assert ContractTerminator.terminate!(@running_contract)
  end

  test "a contract should by default not be terminated" do
    assert_false Contract.first.terminated?
  end

  test "a terminated contract should know it is terminated" do
    terminated_contract = ContractTerminator.terminate!(@running_contract)

    assert terminated_contract.terminated?
  end

  test "terminating a contract should create a new interest entry and final payoff entry" do
    assert_difference ->{AccountingEntry.count}, 2 do
      ContractTerminator.terminate!(@running_contract)
    end
  end

  test "terminating a contract should result in a contract with balance 0 to end of year" do
    terminated_contract = ContractTerminator.terminate!(@running_contract)
    assert_equal 0.0.to_s, terminated_contract.balance(Date.current.end_of_year).to_s
  end

end
