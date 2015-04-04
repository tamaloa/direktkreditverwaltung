class Email < ActiveRecord::Base
  attr_accessible :year, :status, :mail_template, :contact, :contracts
  belongs_to :contact
  belongs_to :mail_template
  has_many :contracts

  validates_uniqueness_of :contact_id, scope: :year
  validates_presence_of :year, :contact_id, :mail_template_id

  after_create :send_email

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
