require 'test_helper'

class ContractVersionTest < ActiveSupport::TestCase

  test "a contract version should only accept dates as date" do
    pending "Implement this" and return
    contract = Contract.first
    assert_raise { contract.contract_versions.create!(start: Time.now, interest_rate: 0.02, version: 12) }
    assert_nothing_raised { contract.contract_versions.create!(start: Date.current, interest_rate: 0.02, version: 12)}
  end

  test "a contract version should warn if interest rate format is not valid" do
    @contract_version = ContractVersion.new(start: Date.current, version: '1')
    invalid_input_for_interest = ['invalid string', '1,5', '1,5%', '1.5%', '1,5', '20.5']
    invalid_input_for_interest.each do |invalid_interest_rate|
      @contract_version.interest_rate = invalid_interest_rate
      refute @contract_version.valid?
    end
    @contract_version.interest_rate = 0.01
    assert @contract_version.valid?
  end

end
