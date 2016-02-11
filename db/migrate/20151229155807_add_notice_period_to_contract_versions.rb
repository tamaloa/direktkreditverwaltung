class AddNoticePeriodToContractVersions < ActiveRecord::Migration
  def change
    add_column :contract_versions, :notice_period, :integer
  end
end
