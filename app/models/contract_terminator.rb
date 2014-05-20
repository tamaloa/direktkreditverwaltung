class ContractTerminator
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :termination_date
  attr_accessor :contract

  validates :termination_date, presence: true
  validates :contract, presence: true

  def initialize(contract_id, params={})
    @contract = Contract.find(contract_id)
    @termination_date = termination_date_to_date(params)
  end

  def terminate!
    errors.add(:base, "Vertrag wurde schon gekündigt") and return false if @contract.terminated_at
    ActiveRecord::Base.transaction do
      @contract.accounting_entries << AccountingEntry.new(amount: final_interest, date: @termination_date, annually_closing_entry: true)
      @contract.accounting_entries << AccountingEntry.new(amount: final_balance, date: @termination_date)
      @contract.terminated_at = @termination_date
      @contract.save
    end

    # contract
  end

  def final_interest
    interest_calculation = InterestCalculation.new(contract, from: @termination_date.beginning_of_year, till: @termination_date)
    interest_calculation.interest_total
  end

  def final_balance
    final_pay_off = -contract.balance(@termination_date)
    final_pay_off

  end


  def persisted?
    false
  end

  private

  def termination_date_to_date(date)
    return unless date
    begin
    return Date.civil(date["termination_date(1i)"].to_i,
               date["termination_date(2i)"].to_i,
               date["termination_date(3i)"].to_i)
    rescue ArgumentError
      nil
    end
  end

end
