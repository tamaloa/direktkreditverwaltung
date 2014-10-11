require 'test_helper'

class ContractVersionTest < ActiveSupport::TestCase

  test "a contract version should only accept dates as date" do
    pending "Implement this" and return
    contract = Contract.first
    assert_raise { contract.contract_versions.create!(start: Time.now, interest_rate: 0.02, version: 12) }
    assert_nothing_raised { contract.contract_versions.create!(start: Date.current, interest_rate: 0.02, version: 12)}
  end

end
