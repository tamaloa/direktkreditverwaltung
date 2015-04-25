class UserMailer < ActionMailer::Base

  def year_closing_statement(email, closing_statements_pdf_files)
    @company = Company.first

    name = email.contact.email
    name = email.contact.prename if email.contact.prename.present?
    name = email.contact.name if name.blank?

    closing_statements_pdf_files.each do |pdf_file_path|
      file = File.read(pdf_file_path)
      attachments[File.basename(pdf_file_path)] = file
    end

    if email.mail_template.newsletter.path.present?
      attachments[email.mail_template.newsletter_file_name] = File.read(email.mail_template.newsletter.path)
    end

    content = email.mail_template.content.gsub(/@geber_in@/, name)

    mail(
      from: @company.email,
      bcc: @company.email,
      to: email.contact.email,
      subject: email.mail_template.subject,
      body: content
    )
  end

end
