module ContractsHelper

  def contract_to_line(contract)
    contract_line = "##{contract.number}"
    contract_line << " - #{contact_short(contract.contact)}"
    contract_line << " - #{currency contract.balance}@#{fraction contract.interest_rate}"
    contract_line << " - X(#{contract.terminated_at})" if contract.terminated_at
    contract_line
  end

  def run_time(contract)
    months = contract.last_version.duration_months
    years = contract.last_version.duration_years
    return "#{months} months" unless months.blank?
    return "#{years} years" unless years.blank?
    "unknown"
  end

  def setup_new_contract(contact)
    contract = Contract.new
    contract.contact = contact
    contract.contract_versions << ContractVersion.new(version: 1)
    contract
  end

end
