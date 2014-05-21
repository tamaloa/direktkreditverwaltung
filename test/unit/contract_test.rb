require 'test_helper'

class ContractTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Date.parse('2011-12-31'))
    @contract = Contract.create_with_balance!(001, 5000, 0.02)
    Timecop.travel(Date.parse('2013-01-01'))
  end

  test "a contract should do a year-end-closing which adds an accounting entry" do
    assert_difference 'AccountingEntry.count' do
      @contract.year_end_closing(2013)
    end
  end

  test "the year_end_closing should always calculate the balance for the last day of the previous year" do
    Timecop.travel(Date.parse('2013-04-23'))
      @contract.year_end_closing(2012)

      assert_equal Date.new(2012,12,31), @contract.accounting_entries.last.date
  end

  test "the year_end_closing should add the interest for last year" do
    @contract.year_end_closing(2013)
    assert_equal @contract.accounting_entries.last.amount, 5000.to_d*0.02
  end

  #test "the year_end_closing should make it impossible to enter additional booking after the closing" do
  #  Timecop.travel(Date.parse('2013-01-01'))
  #  @contract.year_end_closing!
  #
  #
  #  entry = @contract.accounting_entries.new(amount: 300, date: Date.parse('2012-11-13'))
  #  assert !entry.valid?
  #
  #end

  test "terminated contracts should not occur in active scope" do
    active_contract = Contract.find_by_number(9899)
    terminated_contract = Contract.find_by_number(6387)
    assert_not_equal 0, Contract.active.count
    refute Contract.active.all.include?(terminated_contract)
    assert Contract.active.all.include?(active_contract)
  end

  test "active contracts should not occur in terminated scope" do
    active_contract = Contract.find_by_number(9899)
    terminated_contract = Contract.find_by_number(6387)
    assert_not_equal 0, Contract.terminated.count
    refute Contract.terminated.all.include?(active_contract)
    assert Contract.terminated.all.include?(terminated_contract)
  end

end
