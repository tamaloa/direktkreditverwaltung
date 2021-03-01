class InterestCalculation
  attr_reader :contract, :from, :till

  include Days360

  def initialize(contract, params = {})
    @contract = contract
    @year = params[:year] || Date.current.year
    @from = params[:from] || Date.new(@year).beginning_of_year
    @till = params[:till] || @from.end_of_year
  end

  def interest_total
    interest_calculated_for_all_account_activities.map{|a| a[:interest]}.sum
  end

  def pretty_print_movements
    movements = interest_calculated_for_all_account_activities
      p "amount;date;type;interest_rate;interest;days_left_in_year"
    movements.each do |m|
      m.each do |k,v|
        print "#{v.to_s};"
      end
      p ""
    end
  end

  def interest_calculated_for_all_account_activities
    result = []
    interest_rates_and_dates.each do |rate_and_date|
      rate = rate_and_date[:interest_rate]
      from = rate_and_date[:start].to_date
      till = rate_and_date[:end].to_date
      account_movements_with_initial_balance(from, till).each do |movement|
        interest = interest_for(movement[:amount], rate, movement[:date], till)
        result << movement.merge( {interest_rate: rate, interest: interest, days_left_in_year: days360(movement[:date], till)})
      end
    end
    result
  end

  def account_movements_with_initial_balance(from = @from, till = @till)
    account_movements = []
    account_movements << {amount: initial_balance(from), date: from, type: :initial_balance}
    entries = accounting_entries(from, till)
    account_movements = account_movements + entries.map{|entry| {amount: entry.amount, date: entry.date, type: entry.type} }

    account_movements
  end

  def interest_for(amount, interest_rate, from, till)
    days_in_one_year = 360
    total_days = (till.year - from.year + 1) * days_in_one_year
    interest_days = days360(from, till)
    fraction = 1.0 * interest_days / total_days
    interest = (amount * fraction * interest_rate).round(2)
    interest
  end

  def interest_rates_and_dates
    versions = contract_versions_valid_in_set_time_range

    rates_and_dates = []
    versions.each_with_index do |version, index|
      next_version = versions[index+1]
      start_of_current_version = version.start < @from ? @from : version.start
      end_of_current_version = next_version ? next_version.start : @till
      rates_and_dates << {interest_rate: version.interest_rate, start: start_of_current_version, end: end_of_current_version}
    end

    rates_and_dates
  end

  def contract_versions_valid_in_set_time_range
    versions = @contract.contract_versions.where(start: from..till).order(:start)
    last_version_before_interval = @contract.contract_versions.where('start < ?', from).order(:start).last
    versions = [last_version_before_interval] + versions if last_version_before_interval
    versions
  end

  def accounting_entries(from, till)
    if @contract.add_interest_to_deposit_annually
      @contract.accounting_entries.where(:date => from..till).order(:date)
    else
      @contract.accounting_entries.where(interest_entry: false).where(:date => from..till).order(:date)
    end
  end

  def initial_balance(date, only_interest=false)
    first_entry_date = AccountingEntry.minimum(:date)
    till = date-1 #TODO check if this should be last day of old year or not!
    accounting_entries(first_entry_date, till).sum(:amount)
  end

  # We only need this to hack contracts for which no compound interest is to be given
  def sum_of_previous_interests
    first_entry_date = AccountingEntry.minimum(:date)
    interest_movements = @contract.accounting_entries.where(interest_entry: true).where(:date => first_entry_date..@till).order(:date).to_a
    most_recent = interest_movements.pop
    [
    {date: @from, amount: interest_movements.sum(&:amount), type: :sum_of_previous_interests},
    {date: most_recent.date, amount: most_recent.amount, type: :interest_entry}
    ]
  end

end