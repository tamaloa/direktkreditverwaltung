require 'test_helper'

class AccountingEntryTest < ActiveSupport::TestCase

  test "accounting entries should not be createable before a contract starts" do
    @contract = Contract.create_with_balance!(23, 0.0, 0.02)
    invalid_entry =  AccountingEntry.new(date: @contract.start_date - 1.day, amount: 10.0, contract: @contract)
    assert_false invalid_entry.valid?
    @contract.accounting_entries << invalid_entry
    assert_false @contract.save
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
      assert_false entry.valid?
    end
  end

end
