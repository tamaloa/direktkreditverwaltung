# encoding: utf-8

class Contract < ActiveRecord::Base
  include Days360
  # contract representing one account

  belongs_to :contact
  has_many :accounting_entries, order: [:date, :created_at]
  has_many :contract_versions
  attr_accessible :number, :category, :comment , :add_interest_to_deposit_annually
  attr_accessor(:expiring)
  attr_accessor(:remaining_months)

  #account balance for given date
  def balance date = DateTime.now.to_date
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
      return v if v.end_date > date
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

  def interest_entries_act_act year = Date.now.year
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)
    days_in_year = end_date.yday - start_date.yday + 1
    start_balance = balance(start_date)

    days_left = days_in_year
    fraction = days_left/days_in_year
    interest_rate = interest_rate_for_date start_date
    interest = start_balance * fraction * interest_rate
    interest_rows = []
    interest_rows.push({:date => start_date, 
                        :name => "Saldo", 
                        :amount => start_balance,
                        :interest_rate => interest_rate, 
                        :days_left_in_year => days_left, 
                        :fraction_of_year => fraction, 
                        :interest => interest})
    entries = accounting_entries.where(:date => start_date..end_date).order(:date)
    entries.each do |entry|
      days_left = days_in_year - entry[:date].yday + 1
      fraction = 1.0 * days_left/days_in_year
      interest_rate = interest_rate_for_date entry[:date]
      interest = entry[:amount] * fraction * interest_rate
      interest_rows.push({:date => entry[:date],
                          :name => entry.name,
                          :amount => entry[:amount],
                          :interest_rate => interest_rate,
                          :days_left_in_year => days_left,
                          :fraction_of_year => fraction,
                          :interest => interest})
    end
    if contract_versions.length == 1
      return interest_rows
    end
    contract_versions.each do |version|
      if version.start.year == year && !(version.start.month == 1 && version.start.day == 1)
        change_balance = balance(version.start)
        old_interest_rate = interest_rate_for_date(Date.new(version.start.year, 
                                                            version.start.month, 
                                                            version.start.day)-1)
        if old_interest_rate == version.interest_rate
          next
        end
        days_left = days_in_year - version.start + 1
        fraction = 1.0 * days_left/days_in_year
        interest = -change_balance * fraction * old_interest_rate
        interest_rows.push({:date => version.start,
                            :name => "Vertragsänderung",
                            :amount => -change_balance,
                            :interest_rate => old_interest_rate,
                            :days_left_in_year => days_left,
                            :fraction_of_year => fraction,
                            :interest => interest})
        interest = change_balance * fraction * version.interest_rate
        interest_rows.push({:date => version.start,
                            :name => "Vertragsänderung",
                            :amount => change_balance,
                            :interest_rate => version.interest_rate,
                            :days_left_in_year => days_left,
                            :fraction_of_year => fraction,
                            :interest => interest})
      end
    end
    interest_rows
  end

  # XXX refactor with interest_entries_act_act
  def interest_entries_30E_360 year = Date.now.year
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)
    start_balance = balance(start_date)

    interest_rate = interest_rate_for_date start_date
    interest = (start_balance * interest_rate).round(2)
    interest_rows = []
    interest_rows.push({:date => start_date, 
                        :name => "Saldo", 
                        :amount => start_balance,
                        :interest_rate => interest_rate, 
                        :days_left_in_year => 360, 
                        :fraction_of_year => 1, 
                        :interest => interest})
    entries = accounting_entries.where(:date => start_date..end_date).order(:date)
    entries.each do |entry|
      days_left = days360(entry[:date], end_date)
      fraction = 1.0 * days_left/360
      interest_rate = interest_rate_for_date entry[:date]
      interest = (entry[:amount] * fraction * interest_rate).round(2)
      interest_rows.push({:date => entry[:date],
                          :name => entry.name,
                          :amount => entry[:amount],
                          :interest_rate => interest_rate,
                          :days_left_in_year => days_left,
                          :fraction_of_year => fraction,
                          :interest => interest})
    end
    if contract_versions.length == 1
      return interest_rows
    end
    contract_versions.each do |version|
      if version.start.year == year && !(version.start.month == 1 && version.start.day == 1)
        change_balance = balance(version.start)
        old_interest_rate = interest_rate_for_date(Date.new(version.start.year, 
                                                            version.start.month, 
                                                            version.start.day)-1)
        if old_interest_rate == version.interest_rate
          next
        end
        days_left = days360(version.start, end_date)
        fraction = 1.0 * days_left/360
        interest = (-change_balance * fraction * old_interest_rate).round(2)
        interest_rows.push({:date => version.start,
                            :name => "Vertragsänderung",
                            :amount => -change_balance,
                            :interest_rate => old_interest_rate,
                            :days_left_in_year => days_left,
                            :fraction_of_year => fraction,
                            :interest => interest})
        interest = (change_balance * fraction * version.interest_rate).round(2)
        interest_rows.push({:date => version.start,
                            :name => "Vertragsänderung",
                            :amount => change_balance,
                            :interest_rate => version.interest_rate,
                            :days_left_in_year => days_left,
                            :fraction_of_year => fraction,
                            :interest => interest})
      end
    end
    interest_rows.sort_by{|row| row[:date]}
  end

  def interest(year = Time.now.year)
    if SETTINGS[:interest_calculation_method] &&
        SETTINGS[:interest_calculation_method] == "act_act"
      rows = interest_entries_act_act year
    else
      rows = interest_entries_30E_360 year
    end
    interest = rows.inject(0) {|sum, row| sum + row[:interest]}

    # interest = InterestCalculation.new(self, from: Date.new(year)).interest_total
    # rows = InterestCalculation.new(self, from: Date.new(year)).interest_calculated_for_all_account_activities
    return interest, rows
  end


  def self.create_with_balance!(number, balance, interest, start_time = Date.current)
    contract = Contract.create!(number: number)
    last_version = ContractVersion.new
    last_version.version = 1
    last_version.contract_id = contract.id
    last_version.start = start_time
    last_version.interest_rate = interest
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
      c.remaining_months = ((version.end_date - date).to_i/30.5).to_i
      non_zero << c if c.balance(date) > 0
    end
    non_zero.sort_by { |c| c.remaining_months }.reverse
  end

  def year_end_closing(year)
    end_of_last_year = Date.new(year).end_of_year.to_date
    last_years_interest, rows = interest(end_of_last_year.year)

    self.accounting_entries.create!(amount: last_years_interest, date: end_of_last_year, annually_closing_entry: true)
  end

  def terminated?
    return true if terminated_at.is_a?(Date)
    false
  end

end 
