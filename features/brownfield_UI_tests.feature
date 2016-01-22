Feature: As this is a brownfield project we do not want to break UI functionality (just now ;)

Scenario: Creating a new contact
  Given I am an authorized user
  When I create a contact person
  Then there should be a new contact person

Scenario: Registering a payment
  Given I am an authorized user
    And There exists a contract with contact person
  When I register a payment
  Then The balance of the contract should equal the payment

Scenario: Check the yearly interest etc.
  Given I am an authorized user
    And There exists a contract with payments
  When I look at the interest page
  Then I should see the account movements
    And I should see the interest statement
  When I look at the interest transfer page
  Then I should see the interest statement
  When I look at the interest average page
  Then I should see the same interest as given by the one contract
  When I look at the expiring contracts page
  Then I should see the contract

