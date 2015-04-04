class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :mail_template_id
      t.string :status
      t.integer :year
      t.integer :contact_id

      t.timestamps
    end

    create_table :contracts_emails, id: false do |t|
      t.integer :contract_id
      t.integer :email_id
    end
  end
end
