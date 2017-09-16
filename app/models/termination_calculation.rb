class TerminationCalculation
  def self.terminate!(contract, date = Date.current)

    ActiveRecord::Base.transaction do
      contract.accounting_entries << AccountingEntry.new(
        amount: interest_up_to_termination(contract, date),
        date: date,
        interest_entry: true)
      contract.accounting_entries << AccountingEntry.new(
        amount: final_pay_off(contract, date),
        date: date,
        annually_closing_entry: true)
      contract.terminated_at = date
      contract.save!
    end

    contract
  end

  def self.interest_up_to_termination(contract, date)
    interest_calculation = InterestCalculation.new(contract, from: date.beginning_of_year, till: date)
    interest_calculation.interest_total
  end

  def self.final_pay_off(contract, date)
    - contract.balance(date)
  end
end