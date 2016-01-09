class RemoveColumnNumberStringFromContracts < ActiveRecord::Migration
  def change
    remove_column :contracts, :number_string
  end
end
