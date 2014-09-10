class AddInterestFlagToAccountingEntries < ActiveRecord::Migration
  def change
    add_column :accounting_entries, :interest_entry, :boolean, default: false

    # All existing year end closing accounting entries where mostly interest entries
    AccountingEntry.where(annually_closing_entry: true).update_all(interest_entry: true)
  end
end
