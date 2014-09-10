require 'test_helper'

class YearEndClosingTest < ActiveSupport::TestCase

  test "year end closing should only close year on contracts which get interest added annually" do
    Timecop.freeze(Date.parse('2012-12-31'))
    @contract = Contract.create_with_balance!(032, 5000, 0.02)
    @contract.add_interest_to_deposit_annually = false
    @contract.save!

    Timecop.travel(Date.parse('2014-01-23'))
    ending = YearEndClosing.new(:year => 2013)
    assert_difference lambda{contracts('contracts_001').accounting_entries.count} do
      assert_no_difference lambda{ @contract.accounting_entries.count } do
        ending.close_year!
      end
    end

  end

  test "reverting year end closing should delete added annually interest" do
    pending "Reverting all contracts has to be refactored or replaced"
    # Timecop.freeze(Date.parse('2011-12-31'))
    # @contract = Contract.create_with_balance!(032, 5000, 0.02)
    # @contract.add_interest_to_deposit_annually = false
    # @contract.save!
    #
    # Timecop.travel(Date.parse('2013-01-23'))
    # ending = YearEndClosing.new(:year => 2012)
    # ending.close_year!
    #
    # assert_difference lambda{contracts('contracts_001').accounting_entries.count}, -1 do
    #   assert_no_difference lambda{ @contract.accounting_entries.count } do
    #     ending.revert
    #   end
    # end
  end

  test "most_recent_one should return the last one made (chronically)" do
    YearEndClosing.new(:year => 2012).close_year!
    YearEndClosing.new(:year => 2012).close_year!
    YearEndClosing.new(:year => 2013).close_year!

    assert_equal 2013, YearEndClosing.most_recent_one
  end

  test "year end closing should only be created for contract which have already started" do
    @contract = Contract.first
    pending
  end

  test "a contract should do a year-end-closing which adds an accounting entry" do
    @contract = Contract.first
    assert_difference 'AccountingEntry.count' do
      YearEndClosing.new(year: 2013).close_year_for_contract(@contract)
    end
  end

  test "the year_end_closing should always calculate the balance for the last day of the previous year" do
    @contract = Contract.first
    Timecop.travel(Date.parse('2013-04-23'))
      YearEndClosing.new(year: 2012).close_year_for_contract(@contract)

      assert_equal Date.new(2012,12,31), @contract.accounting_entries.last.date
  end

  test "the year_end_closing should not add a entry for already closed contracts" do
    @contract = Contract.find(2)
    assert_no_difference ->{@contract.accounting_entries.count} do
      YearEndClosing.new(year:2012).close_year!
    end
  end

  test "the year_end_closing should add the interest for last year" do
    @contract = Contract.first
    YearEndClosing.new(year: 2013).close_year_for_contract(@contract)
    interest_2013 = InterestCalculation.new(@contract).annual_interest(2013)
    assert_equal interest_2013, @contract.reload.accounting_entries.last.amount
  end

  test "a contract should be closed after performing the year end closing" do
    @contract = Contract.first
    closing = YearEndClosing.new(year: 2013)
    assert_false closing.year_closed?(@contract)
    closing.close_year_for_contract(@contract)
    assert closing.year_closed?(@contract)
  end

  test "a contract should no longer be closed if terminated" do
    pending
  end
end
