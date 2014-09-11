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
      close_year_for_contract(contract)
    end
  end

  def close_year_for_contract(contract)
    return false if contract.start_date.year > @year
    return false if year_closed?(contract)
    last_years_interest = InterestCalculation.new(contract).annual_interest(@year)
    contract.accounting_entries.create!(amount: last_years_interest, date: Date.new(@year).end_of_year,
                                        annually_closing_entry: true, interest_entry: true)
  end

  def year_closed?(contract)
    closing_entry_for_this_year = contract.accounting_entries.only_from_year(@year).where(annually_closing_entry: true)
    return false if closing_entry_for_this_year.empty?
    true
  end

  def revert
    raise "Overthink this ... propably better to only allow single contracts to be reverted"
    end_of_year_date = Date.new(@year).end_of_year.to_date
    AccountingEntry.where(date: end_of_year_date, annually_closing_entry: true).delete_all
    #TODO what to do with terminated contracts (should interest always be deleted)
    #Vielleicht verträge mit terminated at ausschließen
  end

  def self.most_recent_one
    year_closing_entry = AccountingEntry.order('date DESC').where(annually_closing_entry: true).first
    return nil unless year_closing_entry
    year_closing_entry.date.year
  end

  def contracts
    AccountingEntry.where(annually_closing_entry: true).map(&:contract)
  end


  def persisted?
    false
  end

end
