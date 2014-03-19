require 'test_helper'

class YearEndClosingTest < ActiveSupport::TestCase

  test "year end closing should only close year on contracts which get interest added annually" do
    Timecop.freeze(Date.parse('2011-12-31'))
    @contract = Contract.create_with_balance!(032, 5000, 0.02)
    @contract.add_interest_to_deposit_annually = false
    @contract.save!

    Timecop.travel(Date.parse('2013-01-23'))
    ending = YearEndClosing.new(:year => 2012)
    assert_difference lambda{contracts('contracts_001').accounting_entries.count} do
      assert_no_difference lambda{ @contract.accounting_entries.count } do
        ending.close_year!
      end
    end

  end

  test "reverting year end closing should delete added annually interest" do
    Timecop.freeze(Date.parse('2011-12-31'))
    @contract = Contract.create_with_balance!(032, 5000, 0.02)
    @contract.add_interest_to_deposit_annually = false
    @contract.save!

    Timecop.travel(Date.parse('2013-01-23'))
    ending = YearEndClosing.new(:year => 2012)
    ending.close_year!

    assert_difference lambda{contracts('contracts_001').accounting_entries.count}, -1 do
      assert_no_difference lambda{ @contract.accounting_entries.count } do
        ending.revert
      end
    end
  end

  test "most_recent_one should return the last one made (chronically)" do
    YearEndClosing.new(:year => 2011).close_year!
    YearEndClosing.new(:year => 2011).close_year!
    YearEndClosing.new(:year => 2012).close_year!

    assert_equal 2012, YearEndClosing.most_recent_one
  end

end
