require 'test_helper'

class ContractTerminatorTest < ActiveSupport::TestCase

  def setup
    @running_contract = Contract.first
    Timecop.travel(Date.new(2013, 7, 1))
  end

  def teardown
    Timecop.return
  end


  test "contract terminator should terminate a contract" do
    assert TerminationCalculation.terminate!(@running_contract)
  end

  test "a contract should by default not be terminated" do
    refute Contract.first.terminated?
  end

  test "a terminated contract should know it is terminated" do
    terminated_contract = TerminationCalculation.terminate!(@running_contract)

    assert terminated_contract.terminated?
  end

  test "terminating a contract should create a new interest entry and final payoff entry" do
    assert_difference ->{AccountingEntry.count}, 2 do
      TerminationCalculation.terminate!(@running_contract)
    end
  end

  test "terminating a contract should result in a contract with balance 0 to end of year" do
    terminated_contract = TerminationCalculation.terminate!(@running_contract)
    assert_equal 0.0.to_s, terminated_contract.balance(Date.current.end_of_year).to_s
  end

  test "contract terminator should parse date params correctly" do
    params = {"termination_date(3i)"=>"21", "termination_date(2i)"=>"9", "termination_date(1i)"=>"2014"}
    termination = ContractTerminator.new(@running_contract.id, params)
    assert termination.valid?
    assert_equal Date.new(2014,9,21), termination.termination_date
    assert_difference ->{AccountingEntry.count}, 2 do
      termination.terminate!
    end
  end

  test "contract_terminator should be invalid when date params could not be parsed" do
    params = {}
    termination = ContractTerminator.new(@running_contract, params)
    assert ! termination.valid?
  end

end
