# encoding: utf-8

def create_contact
  @contact ||= { :name => "Somebody", :email => "a-somebody@example.com" }
  visit '/contacts/new'
  fill_in "contact_name", :with => @contact[:name]
  fill_in "contact_email", :with => @contact[:email]
  click_button "Fertig"
end

def create_contract
  @contract ||= { :number => 12, :interest => 0.03, :start => Time.now, :duration => 5}
  visit new_contact_contract_path(Contact.find_by_email(@contact[:email]))
  fill_in "contract_number", :with => @contract[:number]
  #date will be set to now (let's just ignore it for now)
  fill_in "last_version_interest_rate", :with => @contract[:interest]
  fill_in "last_version_duration_years", :with => @contract[:duration]
  click_button "Fertig"
end

def create_new_contract_version
  contract = find_contract
  visit new_contract_contract_version_path(contract)
  fill_in "contract_version_version", :with => contract.last_version.version + 1
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

Given(/^I am an authorized user$/) do
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
  create_contract
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
  @contract = Contract.create_with_balance!(1032, 3000.00, 0.03)
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
  extend ApplicationHelper                  #i do not want to include into cucumber env
  extend ActionView::Helpers::NumberHelper

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
  assert contract.contract_versions.count.eql?(2)
end