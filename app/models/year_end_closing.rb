class YearEndClosing
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :year

  validates :year, presence: true
  validates :year, :numericality => true

  def initialize(attributes = {})
    @year = attributes[:year].to_i || Time.now.prev_year.year
  end


  def close_year!
    Contract.where(:add_interest_to_deposit_annually => true).all.each do |contract|
      contract.year_end_closing(@year)
    end
  end

  def revert
    end_of_year_date = Date.new(@year).end_of_year.to_date
    AccountingEntry.where(date: end_of_year_date, annually_closing_entry: true).delete_all
  end

  def self.most_recent_one
    year_closing_entry = AccountingEntry.order('date DESC').where(annually_closing_entry: true).first
    return nil unless year_closing_entry
    year_closing_entry.date.year
  end


  def persisted?
    false
  end

end
