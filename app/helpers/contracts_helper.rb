module ContractsHelper

  def contract_to_line(contract)
    contract_line = "##{contract.number}"
    contract_line << " - #{contact_short(contract.contact)}"
    contract_line << " - #{currency contract.balance}@#{fraction contract.interest_rate}"
    contract_line << " - X(#{contract.terminated_at})" if contract.terminated_at
    contract_line
  end

end
