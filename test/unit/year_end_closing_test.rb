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
    @contract = Contract.find_by_number("6022")
    pending
  end

  test "a contract should do a year-end-closing which adds an accounting entry" do
    @contract = Contract.find_by_number("6022")
    assert_difference 'AccountingEntry.count' do
      YearEndClosing.new(year: 2013).close_year_for_contract(@contract)
    end
  end

  test "the year_end_closing should always calculate the balance for the last day of the previous year" do
    @contract = Contract.find_by_number("6022")
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
    @contract = Contract.find_by_number("6022")
    YearEndClosing.new(year: 2013).close_year_for_contract(@contract)
    interest_2013 = InterestCalculation.new(@contract, year: 2013, method: "30E_360").interest_total
    assert_equal interest_2013, @contract.reload.accounting_entries.last.amount
  end

  test "a contract should be closed after performing the year end closing" do
    @contract = Contract.find_by_number("6022")
    closing = YearEndClosing.new(year: 2013)
    assert_false closing.year_closed?(@contract)
    closing.close_year_for_contract(@contract)
    assert closing.year_closed?(@contract)
  end

  test "a contract should no longer be closed if terminated" do
    closed_contract = Contact.find_by_name('Vor langer Zeit DK gekündigt').contracts.first
    year_after_closing = closed_contract.terminated_at.next_year.year
    closing = YearEndClosing.new(year: year_after_closing)
    assert_no_difference ->{closed_contract.accounting_entries.count} do
      closing.close_year_for_contract(closed_contract)
    end
  end

  test "the year_end_closing all should show all years for which year end closings were created" do
    YearEndClosing.new(:year => 2012).close_year!
    YearEndClosing.new(:year => 2012).close_year!
    YearEndClosing.new(:year => 2013).close_year!

    assert_equal 3, YearEndClosing.all.count
    assert_equal [2013, 2012, 2010], YearEndClosing.all
  end

  test "a year end closing should default to last year" do
    year_end_closing = YearEndClosing.new

    assert_equal 1.year.ago.year, year_end_closing.year
  end
end
