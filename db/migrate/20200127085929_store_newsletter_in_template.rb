class StoreNewsletterInTemplate < ActiveRecord::Migration
  def change
    add_column :mail_templates, :filename, :string
    add_column :mail_templates, :content_type, :string
    add_column :mail_templates, :file_content, :binary
  end
end
