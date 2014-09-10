require 'test_helper'

class AccountingEntryTest < ActiveSupport::TestCase

  test "accounting entries should not be createable before a contract starts" do
    @contract = Contract.first

    invalid_entry =  AccountingEntry.new(date: @contract.start_date - 1.day, amount: 10.0, contract: @contract)
    assert_false invalid_entry.valid?
    @contract.accounting_entries << invalid_entry
    assert_false @contract.save
  end

  test "accounting entries can be added from the day the contract starts" do
    @contract = Contract.first
    valid_entry = AccountingEntry.new(date: @contract.start_date, amount: 10.0, contract: @contract)
    assert valid_entry.valid?

    assert_nothing_raised do
      @contract.accounting_entries << valid_entry
      @contract.save!
    end
  end


end
