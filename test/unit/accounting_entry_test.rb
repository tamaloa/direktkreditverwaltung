require 'test_helper'

class AccountingEntryTest < ActiveSupport::TestCase

  test "accounting entries should not be createable before a contract starts" do
    @contract = Contract.create_with_balance!(23, 0.0, 0.02)
    invalid_entry =  AccountingEntry.new(date: @contract.start_date - 1.day, amount: 10.0, contract: @contract)
    refute invalid_entry.valid?
    @contract.accounting_entries << invalid_entry
    refute @contract.save
  end

  test "accounting entries can be added from the day the contract starts" do
    @contract = Contract.create_with_balance!(23, 0.0, 0.02)
    valid_entry = AccountingEntry.new(date: @contract.start_date, amount: 10.0, contract: @contract)
    assert valid_entry.valid?

    assert_nothing_raised do
      @contract.accounting_entries << valid_entry
      @contract.save!
    end
  end

  test "the year_end_closing should make it impossible to enter additional booking after the closing" do
    Timecop.travel(Date.parse('2012-01-01')) do
      @contract = Contract.first
      entry = @contract.accounting_entries.new(amount: 300, date: Date.parse('2012-11-13'))
      refute entry.valid?
    end
  end

  test "only_from_year should return only entries from the given year" do
    @contract = Contract.create_with_balance!(2323, 0.0, 0.02, Date.new(2013))
    year_before = @contract.accounting_entries.create(date: Date.new(2013), amount: 0.0)
    year_after = @contract.accounting_entries.create(date: Date.new(2015), amount: 0.0)
    in_the_year = @contract.accounting_entries.create(date: Date.new(2014,1,1), amount: 0.0)
    also_in_the_year = @contract.accounting_entries.create(date: Date.new(2014,12,31), amount: 0.0)
    [2014, Date.new(2014,12,31)].each do |date_or_year|
      entries = AccountingEntry.only_from_year(date_or_year)
      refute entries.include?(year_before)
      refute entries.include?(year_after)
      assert entries.include?(in_the_year)
      assert entries.include?(also_in_the_year)
    end
  end

  test "accounting entries should never be created using floats" do
    skip "accounting entries validates amount is not float"
  end

end
