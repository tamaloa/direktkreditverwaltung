class AddEndToContractVersions < ActiveRecord::Migration
  def change
    add_column :contract_versions, :end_date, :date
  end
end
