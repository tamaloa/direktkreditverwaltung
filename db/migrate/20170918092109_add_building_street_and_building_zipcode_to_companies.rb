class AddBuildingStreetAndBuildingZipcodeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :building_street, :string
    add_column :companies, :building_zipcode, :string
  end
end
