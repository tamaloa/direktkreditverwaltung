require 'date'

class InterestCalculation
  attr_reader :contract, :from, :till, :method

  include Days360

  def initialize(contract, params = {})
    @contract = contract
    @year = params[:year] || Date.current.year
    @from = params[:from] || Date.new(@year).beginning_of_year
    @till = params[:till] || @from.end_of_year

    # TODO: find another way to distinguish the interest calculation methods
    if params[:method]
      @method = params[:method]
    elsif Rails.env != "test" && SETTINGS.has_key?(:interest_calculation_method)
      @method = SETTINGS[:interest_calculation_method]
    else
      @method = '30E_360'
    end
  end

  def interest_total
    interest_calculated_for_all_account_activities.map{ |a| a[:interest] }.sum
  end

  # XXX IS THIS FUNCTION STILL IN USE?!
  #def pretty_print_movements
  #  movements = interest_calculated_for_all_account_activities
  #    p "amount;date;type;interest_rate;interest;days_left_in_year"
  #  movements.each do |m|
  #    m.each do |k,v|
  #      print "#{v.to_s};"
  #    end
  #    p ""
  #  end
  #end

  def interest_calculated_for_all_account_activities
    result = []
    # 1. Get the time period and interest-rate for all versions of the given year
    #    (there may have been contract changes e.g. interest-rates)
    interest_rates_and_dates.each do |version_properties|
      version_rate = version_properties[:interest_rate]
      version_from = version_properties[:start].to_date
      version_till = version_properties[:end].to_date
      # 2. Get the initial balance and all 'real' account movements for the given time period
      account_movements_with_initial_balance(version_from, version_till).each do |movement|
        if @method == "act_act"
          interest = interest_actact_for(movement[:amount], version_rate, movement[:date], version_till)
          result << movement.merge({ interest_rate: version_rate,
                                     interest: interest,
                                     days_left_in_year: (version_till - movement[:date]).to_i + 1 })
        else
          interest = interest_for(movement[:amount], version_rate, movement[:date], version_till)
          result << movement.merge({ interest_rate: version_rate,
                                     interest: interest,
                                     days_left_in_year: days360(movement[:date], version_till) })
        end
      end
    end
    result
  end

  # Get the initial balance and all 'real' account movements for a given time period
  def account_movements_with_initial_balance(from = @from, till = @till)
    account_movements = []
    initial_balance = @contract.balance(from-1.day) #TODO check if this should be last day of old year or not!
    initial_balance_date = from

    # 1. Define the initial balance entry for the given time period (initial-balance = Saldo)
    initial_balance_entry = { amount: initial_balance, date: initial_balance_date, type: :initial_balance }

    # 2. Get all 'real' account movements within the given time period
    entries = @contract.accounting_entries.where(:date => from..till).order(:date)

    # 3. Merge it all together
    account_movements << initial_balance_entry
    account_movements = account_movements + entries.map{ |entry| {amount: entry.amount, date: entry.date, type: entry.type} }

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
    # Act-act calculates the interest based on the actual days of a year so that the
    # interest amount for a whole year will be the same whether it's a leap year or not.
    # In the following calculation we assume that year-end-closings are done on a
    # regular basis so that we always look upon a timespan of at most one year hence
    # never more than 366 days.
    days_in_the_year = Date.new(from.year,12,31).yday # would be 356 or 366
    interest_days = (till - (from-1))
    fraction = 1.0 * interest_days / days_in_the_year
    interest = (amount * fraction * interest_rate)
    interest.round(2)
  end

  # method currently not used but maybe useful for ad-hoc interest calculations
  # expects data_per_year = { :year => ..., :total_days => ..., :interest_days => ... }
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
      rates_and_dates << { interest_rate: version.interest_rate, 
                           start: start_of_current_version, 
                           end: end_of_current_version }
    end

    rates_and_dates
  end

  # Returns all versions of year and last version before
  def contract_versions_valid_in_set_time_range
    versions_within_timerange = @contract.contract_versions.where(start: from..till).order(:start)
    if versions_within_timerange.length > 0 &&
       versions_within_timerange.first.start == from
      # exit here because we don't need an earlier version
      return versions_within_timerange
    end

    all_versions = versions_within_timerange
    last_version_before_interval = @contract.contract_versions.where('start < ?', from).order(:start).last
    all_versions = [last_version_before_interval] + all_versions if last_version_before_interval

    all_versions
  end

end