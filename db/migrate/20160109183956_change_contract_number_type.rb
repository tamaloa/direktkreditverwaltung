class ChangeContractNumberType < ActiveRecord::Migration
  def change
    change_column :contracts, :number, :string
  end
end
