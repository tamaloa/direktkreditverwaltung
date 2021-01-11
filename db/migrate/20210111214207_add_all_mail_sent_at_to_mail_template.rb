class AddAllMailSentAtToMailTemplate < ActiveRecord::Migration
  def change
    add_column :mail_templates, :all_mail_sent_at, :datetime

    MailTemplate.find_each do |template|
      template.update(all_mail_sent_at: template.emails.map(&:created_at).max)
    end
  end
end
