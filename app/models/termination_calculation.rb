class TerminationCalculation
  def self.terminate!(contract, date = Date.current)

    ActiveRecord::Base.transaction do
      contract.accounting_entries << AccountingEntry.new(amount: final_interest(contract, date), date: date, annually_closing_entry: true)
      contract.accounting_entries << AccountingEntry.new(amount: final_balance(contract, date), date: date)
      contract.terminated_at = date
      contract.save
    end

    contract
  end

  def self.final_interest(contract, date)
    interest_calculation = InterestCalculation.new(contract, from: date.beginning_of_year, till: date)
    interest_calculation.interest_total
  end

  def self.final_balance(contract, date)
    final_pay_off = -contract.balance(date)
    final_pay_off
  end
end