class ContractTerminator

  def self.terminate!(contract, date = Time.now.to_date)
    ActiveRecord::Base.transaction do
      add_final_interest(contract, date)
      deduce_final_balance(contract, date)
      contract.terminated_at = date
      contract.save
    end

    contract
  end

  def self.add_final_interest(contract, date)
    interest_calculation = InterestCalculation.new(contract, from: date.beginning_of_year, till: date)
    final_interest = interest_calculation.interest_total

    contract.accounting_entries.create!(amount: final_interest, date: date, annually_closing_entry: true)
  end

  def self.deduce_final_balance(contract, date)
    final_pay_off = -contract.balance(date)
    contract.accounting_entries.create!(amount: final_pay_off, date: date, annually_closing_entry: true)
  end


end
