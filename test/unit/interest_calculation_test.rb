require 'test_helper'

class InterestCalculationTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Date.new(2013))
    @contract = Contract.find_by_number("6022") # a contract for which rate was changed 2012-07-01
  end

  def teardown
    Timecop.return
  end

  test "a list of interest rates with start and end should be returned" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2000), till: Date.new(2020))
    assert_equal @contract.contract_versions.count, interest_calculation.interest_rates_and_dates.count
  end

  test "only those interest rates should be returned which fall into the time interval" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2012, 7, 2), till: Date.new(2012, 8, 2))

    assert_equal 1, interest_calculation.interest_rates_and_dates.count
    assert_equal 0.02.to_d, interest_calculation.interest_rates_and_dates.first[:interest_rate]
  end


  test "account movements should always contain a initial balance entry even for far future dates" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2200))
    assert_equal 1, interest_calculation.account_movements_with_initial_balance.count
  end

  test "account movements should contain one entry for each movement plus initial balance" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2000), till: Date.new(2020))
    assert_equal (@contract.accounting_entries.count + 1), interest_calculation.account_movements_with_initial_balance.count
  end

  test "interest_calculated_for_all_account_activities" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2012, 1, 1), till: Date.new(2012, 12, 31))

    expected_rows = 0
    expected_rows += 1 #initial row with balance from last year?
    expected_rows += 1 #one row for change in rate
    expected_rows += @contract.accounting_entries.count #we only have them in 2012

    assert_equal expected_rows, interest_calculation.interest_calculated_for_all_account_activities.count

  end

  test "interest (30E_360) total should be calculated correctly" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2012, 1, 1), till: Date.new(2012, 12, 31), method: "30E_360")
    assert_equal 78.0.to_s, interest_calculation.interest_total.to_s
    assert_equal 78.0.to_s, InterestCalculation.new(@contract, year: 2012).interest_total.to_s
  end

  test "interest (act_act) total should be calculated correctly" do
    interest_calculation = InterestCalculation.new(@contract, from: Date.new(2012, 1, 1), till: Date.new(2012, 12, 31), method: "act_act")
    assert_equal 78.0.to_s, interest_calculation.interest_total.to_s
    assert_equal 78.0.to_s, InterestCalculation.new(@contract, year: 2012, method: "act_act").interest_total.to_s
  end

end
