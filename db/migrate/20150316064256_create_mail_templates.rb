class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      t.string :subject
      t.text :content
      t.text :footer
      t.integer :year

      t.timestamps
    end

    add_attachment :mail_templates, :newsletter
  end
end
