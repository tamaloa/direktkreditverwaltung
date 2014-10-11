class YearClosingStatement
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :year, :contract

  validates_presence_of :year, :contract
  validates :year, numericality: true

  def initialize(attributes = {})
    @year = attributes[:year].to_i
    @contract = attributes[:contract]
  end

  def movements
    #Maybe this model is the better place to create the movements initial and final balance?
    #But InterestCalculation needs the change movements any way ...
    movements = InterestCalculation.new(contract, year: year).account_movements_with_initial_balance
    movements << years_last_movement
  end

  def years_last_movement
    last_movement_type = :annual_interest if year_closed?
    last_movement_type = :unsure_interest unless year_closed?
    {amount: annual_interest, date: Date.new(year).end_of_year, type: last_movement_type}
  end

  def balance_start_of_year
    movements.first[:amount]
  end
  def year_closed?
    YearEndClosing.new(year: year).year_closed?(contract)
  end

  def annual_interest
    InterestCalculation.new(contract, year: year).interest_total
  end
  def balance_closing_of_year
    #Should we rather use InterestCalculation all the way through?
    contract.balance(Date.new(year + 1, 1, 1))
  end

  def persisted?
    false
  end

end
