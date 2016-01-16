require 'date'

class InterestCalculation
  attr_reader :contract, :from, :till, :method

  include Days360

  def initialize(contract, params = {})
    @contract = contract
    @year = params[:year] || Date.current.year
    @from = params[:from] || Date.new(@year).beginning_of_year
    @till = params[:till] || @from.end_of_year

    if params[:method]
      @method = params[:method]
    elsif SETTINGS[:interest_calculation_method] != nil
      @method = SETTINGS[:interest_calculation_method]
    else
      @method = '30E_360'
    end

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
        if @method == "act_act"
          interest = interest_actact_for(movement[:amount], rate, movement[:date], till)
          result << movement.merge({ interest_rate: rate,
                                     interest: interest,
                                     days_left_in_year: (till - movement[:date]).to_i + 1 })
        else
          interest = interest_for(movement[:amount], rate, movement[:date], till)
          result << movement.merge({ interest_rate: rate,
                                     interest: interest,
                                     days_left_in_year: days360(movement[:date], till) })
        end
      end
    end
    result
  end

  def account_movements_with_initial_balance(from = @from, till = @till)
    account_movements = []
    initial_balance = @contract.balance(from-1.day) #TODO check if this should be last day of old year or not!
    account_movements << {amount: initial_balance, date: from, type: :initial_balance}
    entries = @contract.accounting_entries.where(:date => from..till).order(:date)
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

  def interest_actact_for(amount, interest_rate, from, till)
    # act-act calculates interest based on actual days of a year
    data_per_year = []
    if from.year == till.year
      # timespan within one year
      data_per_year << { :year => from.year,
                         :total_days => Date.new(from.year,12,31).yday,
                         :interest_days => (till - from) }
    else
      year_diff = till.year - from.year
      # calculate values for each year
      for i in 0..year_diff
        current_year = from.year + i
        entry = { :year => current_year,
                  :total_days => Date.new(current_year,12,31).yday }

        if i == 0
          # from-year, without first day
          entry[:interest_days] = entry[:total_days] - from.yday
        elsif i == year_diff
          # till-year
          entry[:interest_days] = till.yday
        else
          # years in between
          entry[:interest_days] = entry[:total_days]
        end

        data_per_year << entry
      end
    end

    actact_interest_total(data_per_year, amount, interest_rate)
  end

  def actact_interest_total(data_per_year, initial_amount, interest_rate)
    interest_total = 0
    actual_amount = initial_amount
    data_per_year.each do |entry|
      fraction = 1.0 * entry[:interest_days] / entry[:total_days]
      interest = (actual_amount * fraction * interest_rate)
      interest_total += interest
      # mind the zinseszins (for next year) - Rendite! Rendite! Rendite!
      actual_amount += interest
    end
    interest_total.round(2)
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

end