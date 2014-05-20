class AddTerminationDateToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :terminated_at, :date, :default => nil
    add_index :contracts, :terminated_at
  end
end
