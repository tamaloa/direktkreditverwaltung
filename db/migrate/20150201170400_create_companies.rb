class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :gmbh_name
      t.string :verein_name
      t.string :street
      t.string :zip_code
      t.string :city
      t.string :email
      t.string :web
      t.string :bank_name
      t.string :bank_account_info
      t.string :gmbh_executive_board
      t.string :gmbh_register_number
      t.string :gmbh_tax_number

      t.timestamps
    end
  end
end
