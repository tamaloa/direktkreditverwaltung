require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  test "company.first_or_default should always return a company" do
    assert Company.first_or_default.is_a?(Company)
    Company.delete_all
    assert Company.first_or_default.is_a?(Company)
  end
end
