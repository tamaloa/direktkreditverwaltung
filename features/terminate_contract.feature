Feature: A contract may be terminated to a given date. The amount of money to be payed back should be displayed.

Scenario: Terminating a contract
  Given I am an authorized user
  And There exists a contract with payments
  When I terminate the contract 3 months from now
  Then I should see the amount to pay back

