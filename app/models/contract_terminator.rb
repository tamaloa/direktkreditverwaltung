class ContractTerminator
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  include ParamsToDate

  attr_accessor :termination_date
  attr_accessor :contract

  validate :termination_date, presence: true
  validate :contract, presence: true
  validate :termination_date_is_valid
  validate :contract_ready_for_termination

  def initialize(contract_id, params={})
    @contract = Contract.find(contract_id)
    @termination_date = date_select_params_to_date(params, :termination_date)
  end

  def terminate!
    TerminationCalculation.terminate!(@contract, @termination_date)
  end


  def persisted?
    false
  end

  private

  def termination_date_is_valid
    errors.add(:termination_date, "Invalid Date!") and return false unless @termination_date.is_a?(Date)
  end

  def contract_ready_for_termination
    errors.add(:base, "Vertrag wurde schon gekündigt") and return false if @contract.terminated_at
  end

end
