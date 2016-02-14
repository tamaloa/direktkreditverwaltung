def create_contact
  @contact ||= { :name => "Somebody", :email => "a-somebody@example.com" }
  visit '/contacts/new'
  fill_in "contact_name", :with => @contact[:name]
  fill_in "contact_email", :with => @contact[:email]
  click_button "Fertig"
end

def create_contract
  fill_in_new_contract_form
  submit_new_contract_form
end

def submit_new_contract_form
  click_button "Fertig"
end

def fill_in_new_contract_form
  @contract ||= { :number => '12', :interest => 0.03, :start => Time.now, :duration => 5}
  visit new_contact_contract_path(Contact.find_by_email(@contact[:email]))
  fill_in "contract_number", :with => @contract[:number]
  #date will be set to now (let's just ignore it for now)
  fill_in "contract_contract_versions_attributes_0_duration_years", :with => @contract[:duration]
  fill_in "contract_contract_versions_attributes_0_interest_rate", :with => @contract[:interest]
end

def create_new_contract_version
  contract = find_contract
  visit new_contract_contract_version_path(contract)
  fill_in "contract_version_version", :with => contract.last_version.version + 1
  select_date_from_date_field(Date.current, :contract_version, :start)
  fill_in "contract_version_interest_rate", :with => 0.05
  click_button "Fertig"
end

def find_contract
  Contract.find_by_number(@contract[:number])
end

def create_accounting_entry
  @accounting_entry ||= { :amount => 1000, :date => Time.now }
  visit new_contract_accounting_entry_path(find_contract)
  fill_in "accounting_entry_amount", :with => @accounting_entry[:amount]
  #date will be set to time.now
  click_button "Fertig"
end

When /^I select "([^"]*)" as the (.+) "([^"]*)" date$/ do |date, model, selector|
  select_date_from_date_field(date, model, selector)
end

Given(/^I am an authorized user$/) do
  @company ||= Company.first_or_create
  true #We do not have authorization in place
end

When(/^I create a contact person$/) do
  create_contact
end

Then(/^there should be a new contact person$/) do
  assert Contact.find_by_email(@contact[:email])
end

And(/^There exists a contact person$/) do
  create_contact
end


When(/^I create a contract$/) do
  fill_in_new_contract_form
  submit_new_contract_form
end

When(/^I create a contract with invalid interest rate$/) do
  fill_in_new_contract_form
  fill_in "contract_contract_versions_attributes_0_interest_rate", :with => 'invalid 1,%'
  submit_new_contract_form
end

Then(/^There should exist a new contract for the contact person$/) do
  contract = find_contract
  assert contract
  contact = Contact.find_by_email(@contact[:email])
  assert contract.contact.eql?(contact)
end

And(/^There exists a contract with contact person$/) do
  create_contact
  create_contract
end

When(/^I register a payment$/) do
  create_accounting_entry
end

Then(/^The balance of the contract should equal the payment$/) do
  contract = find_contract
  assert contract.balance.eql?(1000)
end

And(/^There exists a contract with payments$/) do
  create_contact
  create_contract
  create_accounting_entry
end

And(/^There exists an anonymous contract with payments$/) do
  @contract = Contract.create_with_balance!("1032", 3000.00, 0.03)
  create_accounting_entry
end

When(/^I look at the interest page$/) do
  visit '/contracts/interest'
end

Then(/^I should see the account movements$/) do
  assert page.has_content?("Saldo")
  assert page.has_content?('Einzahlung 	1.000,00 € 	3,00%')
end

Then(/^I should see the interest statement$/) do
  assert page.has_content?("Direktkreditvertrag Nr. #{@contract[:number]}, #{@contact[:name] if @contact}")
  contract = find_contract
  interest, interest_calculation = contract.interest #This is soo in need of refactoring
  assert page.has_content?(currency(interest))
end

When(/^I look at the interest transfer page$/) do
  visit '/contracts/interest_transfer_list'
end

When(/^I look at the interest average page$/) do
  visit '/contracts/interest_average'
end

Then(/^I should see the same interest as given by the one contract$/) do
  assert page.has_content?("Durchschnittlicher Zinssatz: 3,00%")
end

When(/^I look at the expiring contracts page$/) do
  visit '/contracts/expiring'
end

Then(/^I should see the contract$/) do
  assert page.has_content?(@contract[:number])
end

Then(/^I should not see the contract$/) do
  refute page.has_content?(@contract[:number])
end


When(/^I create a new contract version$/) do
  create_new_contract_version
end


Then(/^There should exist two contract versions$/) do
  contract = find_contract
  assert_equal 2, contract.contract_versions.count
end


When(/^I terminate the contract 3 months from now$/) do
  contract = find_contract
  visit new_contract_terminator_path(id: contract.id)
  termination_date = 3.months.from_now
  select_date_from_date_field(termination_date, :contract_terminator, :termination_date)
  click_button "Vertrag auflösen"

end

Then(/^I should see the amount to pay back$/) do
  assert page.has_content?(find_contract.accounting_entries.last.amount.to_s)
end

Then(/^I should see "(.*)"$/) do |some_string|
  assert page.has_content?(some_string)
end

def select_date_from_date_field(date, model_name, attribute_name)
  select date.year.to_s, from: "#{model_name}_#{attribute_name}_1i"
  select I18n.localize(date, :format => '%B'), from: "#{model_name}_#{attribute_name}_2i"
  select date.day.to_s, from: "#{model_name}_#{attribute_name}_3i"
end