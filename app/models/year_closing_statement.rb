class YearClosingStatement < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :year, :contract_id

  def all_movements
    #Maybe this model is the better place to create the movements initial and final balance?
    #But InterestCalculation needs the change movements any way ...
    InterestCalculation.new(contract, year: year).account_movements_with_initial_balance
  end
  def balance_closing_of_year_before
    all_movements.first[:amount]
  end

  def annual_interest(contract)
    InterestCalculation.new(contract, year: year).interest_total
  end
  def balance_closing_of_year(contract)
    #Should we rather use InterestCalculation all the way through?
    contract.balance(Date.new(year + 1, 1, 1))
  end

end
