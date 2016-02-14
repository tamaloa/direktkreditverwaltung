# contract representing one account
class Contract < ActiveRecord::Base
  include Days360

  belongs_to :contact
  has_many :accounting_entries, order: [:date, :created_at]
  has_many :contract_versions

  accepts_nested_attributes_for :contract_versions#, reject_if: :all_blank
  attr_accessible :contract_versions_attributes

  validate :number, with: [:presence, :uniqueness]

  default_scope { order(:number) }
  scope :active, ->{ where(terminated_at: nil)}
  scope :terminated, ->{ where('terminated_at IS NOT NULL')}
  attr_accessible :number, :category, :comment, :add_interest_to_deposit_annually
  attr_accessor(:expiring)
  attr_accessor(:remaining_months)

  def start_date
    return false if contract_versions.empty?
    contract_versions.first.start
  end
  #account balance for given date
  def balance(date = DateTime.now.to_date)
    accounting_entries.where("date <= ?", date).sum(:amount)
  end

  def interest_rate(date = Date.current)
    interest_rate_for_date(date)
  end

  #XXX: find better query and do it in controller, making last_version an alias
  # in the contract table (if better?)
  def last_version
    contract_versions.where("start = ?", contract_versions.maximum(:start)).first
  end

  def version_of date
    versions = contract_versions.where("start <= ?", date).order('start').reverse
    versions.each do |v|
      return v if !v.is_open_ended && (v.calculate_end_date > date)
    end
    logger.warn "contract '#{id}' has no version for this request" 
    return last_version
  end

  def interest_rate_for_date date
    versions = contract_versions.order(:start).reverse_order
    versions.each do |version|
      if version.start <= date
        return version.interest_rate
      end
    end
    logger.warn "date before start date of first contract version. Returning interest_rate = 0"
    return 0.0
  end

  def interest(year = Time.now.year)
    interest = InterestCalculation.new(self, from: Date.new(year)).interest_total
    rows = InterestCalculation.new(self, from: Date.new(year)).interest_calculated_for_all_account_activities
    return interest, rows
  end


  def self.create_with_balance!(number, balance, interest, start_time = Date.current, params = {})
    contract = Contract.create!(number: number)
    last_version = ContractVersion.new
    last_version.version = 1
    last_version.contract_id = contract.id
    last_version.start = start_time
    last_version.interest_rate = interest
    params.each do |key, value|
      last_version[key] = value
    end
    last_version.save!
    contract.accounting_entries.create!(amount: balance, date: start_time)

    contract
  end

  def self.all_with_remaining_month(year)
    date = Date.new(year, 12, 31)
    non_zero = []
    contracts = Contract.all
    contracts.each do |c|
      version = c.version_of(date)
      # only fixed-term contracts get remaining_months attached
      if !version.is_open_ended
        c.remaining_months = ((version.calculate_end_date - date).to_i/30.5).to_i
      end
      non_zero << c if c.balance(date) > 0
    end
    non_zero # XXX TODO: non_zero.sort_by { |c| c.remaining_months }.reverse
  end

  def terminated?
    return true if terminated_at.is_a?(Date)
    false
  end

end 
