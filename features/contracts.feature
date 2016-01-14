Feature: Creating Contracts should be easy and assisted by appropriate error messages.

Scenario: Creating a contract
  Given I am an authorized user
    And There exists a contact person
  When I create a contract
  Then There should exist a new contract for the contact person

Scenario: Creating a second contract version
  Given I am an authorized user
  And There exists a contract with contact person
  When I create a new contract version
  Then There should exist two contract versions

Scenario: Creating a invalid contract
  Given I am an authorized user
    And There exists a contact person
  When I create a contract with invalid interest rate
  Then I should see "Zinssatz ungültig"