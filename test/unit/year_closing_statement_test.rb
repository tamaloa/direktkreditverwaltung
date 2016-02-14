require 'test_helper'

class YearClosingStatementTest < ActiveSupport::TestCase

  test "the year end closing should contain the years accounting entries" do
    contract = create_contract
    3.times do
      contract.accounting_entries.create(amount: 1000, date:1.year.ago.to_date)
    end

    statement = YearClosingStatement.new(contract: contract, year: 1.year.ago.year)
    assert statement.movements.count >= 3
  end

  test "a new contracts statement initial years balance should be zero" do
    contract = create_contract
    statement = YearClosingStatement.new(contract: contract, year: 1.year.ago.year)
    assert_equal "0.0", statement.balance_start_of_year.to_s
  end

  test "a contract statement should indicate if the year has been closed" do
    contract = create_contract
    statement = YearClosingStatement.new(contract: contract, year: 1.year.ago.year)

    assert_respond_to statement, :year_closed?
    refute statement.year_closed?

  end

  test "a contract statement should contain a unfinished closing movement" do
    contract = create_contract
    statement = YearClosingStatement.new(contract: contract, year: 1.year.ago.year)

    assert_equal "0.0", statement.annual_interest.to_s
  end

  test "the statement movements contain all movements including start balance and an interest entry" do
    contract = create_contract
    contract.accounting_entries.create(amount: 10.0, date: 1.year.ago.to_date)
    statement = YearClosingStatement.new(contract: contract, year: 1.year.ago.year)

    assert_equal 3, statement.movements.count
  end


end
