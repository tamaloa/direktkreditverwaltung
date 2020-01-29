class YearEndClosing
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :year

  validates :year, presence: true
  validates :year, :numericality => true

  def initialize(attributes = {})
    @year = attributes[:year] || Time.now.prev_year.year
    @year = @year.to_i #TODO fix this on controller side with strong params?
  end


  def close_year!
    Contract.where(add_interest_to_deposit_annually: true).each do |contract|
      close_year_for_contract(contract)
    end
  end

  def close_year_for_contract(contract)
    return false if contract.start_date.year > @year
    return false if year_closed?(contract)
    return false if contract.terminated_at.present?
    last_years_interest = InterestCalculation.new(contract, year: @year).interest_total
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
    year_closing_entry = AccountingEntry.
        order('date DESC').where(annually_closing_entry: true).
        reject{|e| e.contract.terminated_at.present?}.first
    return nil unless year_closing_entry
    year_closing_entry.date.year
  end

  def self.next_one
    return 7.years.ago.year unless most_recent_one
    most_recent_one + 1
  end

  def self.all
    AccountingEntry.where(annually_closing_entry: true).map{|entry| entry.date.year}.uniq.sort.reverse
  end

  def contracts
    AccountingEntry.only_from_year(@year).where(annually_closing_entry: true).map(&:contract)
  end

  def email_all_closing_statements
    mail_template = MailTemplate.find_by_year(@year)
    contacts_and_contracts_with_email.each do |contact, contracts|
      Email.create!(contact: contact,
                    mail_template: mail_template,
                    year: @year,
                    contracts: contracts)
    end
  end

  def contacts_and_contracts_with_email
    contracts.group_by(&:contact).reject{|contact, contract| contact.blank? || contact.email.blank?}
  end

  def contacts_and_contracts_without_email
    contracts.group_by(&:contact).select{|contact, contract| contact.blank? || contact.email.blank?}
  end

  #TODO: This really belongs some where else
  require 'csv'
  def as_csv
    CSV.generate do |csv|
      csv << ['DK#', 'DK Geber_in', 'Vorjahressaldo', 'Kontobewegungen', 'Zinssätze', 'Zinsen', 'Saldo Jahresabschluss']
      contracts.each do |contract|
        row = []
        row << contract.number
        row << ApplicationController.helpers.contact_short(contract.contact)
        row << ApplicationController.helpers.currency(balance_closing_of_year_before(contract))
        row << movements_excluding_interest(contract).join("\n")
        row << interest_rates(contract).join("\n")
        row << ApplicationController.helpers.currency(annual_interest(contract))
        row << ApplicationController.helpers.currency(balance_closing_of_year(contract))
        csv << row
      end
    end
  end

  def persisted?
    false
  end
  def to_param
    year
  end

  #We might want to move this into a separate model/presenter soon
  def balance_closing_of_year_before(contract)
    movement = InterestCalculation.new(contract, year: @year).account_movements_with_initial_balance.first
    movement[:amount]
  end
  def movements_excluding_interest(contract)
    movements = InterestCalculation.new(contract, year: @year).account_movements_with_initial_balance
    without_initial_balance = movements.drop(1) # Initial balance
    only_non_interest = without_initial_balance.reject{|m| m[:type] == :interest_entry}
    only_non_interest.map{|m| m[:date].iso8601 + ' ' + m[:amount].to_s + ' €'}
  end
  def interest_rates(contract)
    rates_and_dates = InterestCalculation.new(contract, year: @year).interest_rates_and_dates
    return ["#{rates_and_dates.first[:interest_rate].to_s} %"] if (rates_and_dates.count == 1)
    rates_and_dates.map do |rad|
      "#{rad[:start]} bis #{rad[:end]} Zinssatz: #{rad[:interest_rate].to_s} %"
    end
  end
  def annual_interest(contract)
    InterestCalculation.new(contract, year: @year).interest_total
  end
  def balance_closing_of_year(contract)
    movement = InterestCalculation.new(contract, year: @year+1).account_movements_with_initial_balance.first
    movement[:amount]
  end

end
