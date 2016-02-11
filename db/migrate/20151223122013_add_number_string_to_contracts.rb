class AddNumberStringToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :number_string, :string
  end
end
