Given(/^The date is "(.*?)"$/) do |date|
  Timecop.freeze(Date.parse(date))
end

Given(/^DK contract (\d+) has a balance of (\d+\.\d+) euro and interest of (\d+\.\d+)%$/) do |dk_number, balance, interest|
  balance = balance.to_f
  interest = interest.to_f/100
  Contract.create_with_balance!(dk_number, balance, interest)
end

When(/^Time passes$/) do
  true #always
end

When(/^Time passes and it is the "(.*?)"$/) do |date|
  Timecop.travel(Date.parse(date))
end

When(/^For DK contract (\d+) a deposit of (\d+\.\d+) euro is made on the "(.*?)"$/) do |dk_number, deposit, date|
  contract = Contract.find_by_number(dk_number)
  deposit = deposit.to_f
  contract.accounting_entries.create!(amount: deposit, date: Date.parse(date))
end


When(/^For DK contract (\d+) a payback of (\d+\.\d+) euro is made on the "(.*?)"$/) do |dk_number, payback, date|
  contract = Contract.find_by_number(dk_number)
  payback = -(payback.to_f)
  contract.accounting_entries.create!(amount: payback, date: Date.parse(date))
end

Then(/^The balance including interest of DK contract (\d+) is (\d+\.\d+) euro$/) do |dk_number, final_balance|
  contract = Contract.find_by_number(dk_number)
  final_balance = BigDecimal.new(final_balance)
  calculated_balance = contract.balance
  calculated_interest, rows = contract.interest
  assert_equal final_balance.to_s, (calculated_balance + calculated_interest).round(2).to_s
end

And(/^DK contracts as described in "(.*?)" exist$/) do |csv_file|
  Import.contracts(csv_file)
end

And(/^The deposits and paybacks as described in "(.*?)" occur$/) do |csv_file|
  Import.accounting_entries(csv_file)
end


When(/^For DK contract (\d+) the interest changes to (\d+\.\d+)% on the "(.*?)"$/) do |dk_number, new_interest, date|
  contract = Contract.find_by_number(dk_number)
  contract.contract_versions.create(:interest_rate => new_interest.to_f/100, :start => Date.parse(date), :version => 2)
end