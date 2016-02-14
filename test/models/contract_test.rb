require 'test_helper'

class ContractTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Date.parse('2011-12-31'))
    @contract = Contract.create_with_balance!(001, 5000, 0.02)
    Timecop.travel(Date.parse('2013-01-01'))
  end





  test "terminated contracts should not occur in active scope" do
    active_contract = Contract.find_by_number("9899")
    terminated_contract = Contract.find_by_number("6387")
    assert_not_equal 0, Contract.active.count
    refute Contract.active.all.include?(terminated_contract)
    assert Contract.active.all.include?(active_contract)
  end

  test "active contracts should not occur in terminated scope" do
    active_contract = Contract.find_by_number("9899")
    terminated_contract = Contract.find_by_number("6387")
    assert_not_equal 0, Contract.terminated.count
    refute Contract.terminated.all.include?(active_contract)
    assert Contract.terminated.all.include?(terminated_contract)
  end

  test "contract should have a last version" do
    assert Contract.find_by_number("9899").last_version
  end

end
