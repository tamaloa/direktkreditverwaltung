require 'test_helper'

class ContractTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Date.parse('2011-12-31'))
    @contract = Contract.create_with_balance!(001, 5000, 0.02)
    Timecop.travel(Date.parse('2013-01-01'))
  end

  test "a contract should do a year-end-closing which adds an accounting entry" do
    assert_difference 'AccountingEntry.count' do
      @contract.year_end_closing!
    end
  end

  test "the year_end_closing should always calculate the balance for the last day of the previous year" do
    Timecop.travel(Date.parse('2013-04-23'))
      @contract.year_end_closing!

      assert @contract.accounting_entries.last.date.eql?(Date.parse('2012-12-31'))
  end

  test "the year_end_closing should add the interest for last year" do
    @contract.year_end_closing!
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


end
