class AddTestMailSentAtTimestampsToMailTemplate < ActiveRecord::Migration
  def change
    add_column :mail_templates, :test_mail_sent_at, :timestamp
  end
end
