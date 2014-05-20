module ContractsHelper

  def contract_to_line(contract)
    "#{contract.number} - #{contract.contact.try(:name)} - #{currency contract.balance} - #{fraction contract.interest_rate}"
  end

end
