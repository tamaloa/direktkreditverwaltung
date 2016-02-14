class Email < ActiveRecord::Base

  belongs_to :contact
  belongs_to :mail_template
  has_and_belongs_to_many :contracts

  validates_uniqueness_of :contact_id, scope: :year
  validates_presence_of :year, :contact_id, :mail_template_id

  after_create :send_email

  def self.send_test_email(year, email_to)
    contact = Contact.new(name: "[Test-Email #{year}]", email: email_to)
    contract_one = Contract.first
    contract_two = Contract.last #TODO: Contract.new_random
    mail_template = MailTemplate.find_by_year(year)
    test_mail = Email.new(year: year, contact: contact, mail_template: mail_template,
                          contracts: [contract_one, contract_two])

    UserMailer.year_closing_statement(test_mail, test_mail.closing_statements_pdf_files).deliver
    mail_template.update_attribute(:test_mail_sent_at, Time.now)
  end

  def send_email
    UserMailer.year_closing_statement(self, closing_statements_pdf_files).deliver
  end

  def closing_statements_pdf_files
    statements_to_file = StatementsToFile.new(YearEndClosing.new(year: self.year))
    closing_statement_filenames = []
    contracts.each do |contract|
      closing_statement_filenames << statements_to_file.to_pdf(contract)
    end
    closing_statement_filenames
  end

end
