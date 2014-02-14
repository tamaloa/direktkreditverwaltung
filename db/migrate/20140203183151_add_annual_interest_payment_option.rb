class AddAnnualInterestPaymentOption < ActiveRecord::Migration
  def change
    add_column :contracts, :add_interest_to_deposit_annually, :boolean, :default => true

    #previous only contracts without this option were available
    Contract.update_all(:add_interest_to_deposit_annually => false)


    add_column :accounting_entries, :annually_closing_entry, :boolean, :default => false

    #all existing entries are of course not an annually closing entry
    AccountingEntry.update_all(:annually_closing_entry => false)

  end
end
