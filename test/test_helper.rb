require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def create_contract
    contract = Contract.create!(number: 42243213)
    last_version = ContractVersion.new
    last_version.version = 1
    last_version.contract_id = contract.id
    last_version.start = 2.years.ago
    last_version.interest_rate = 0.023
    last_version.save!

    contract
  end
end
