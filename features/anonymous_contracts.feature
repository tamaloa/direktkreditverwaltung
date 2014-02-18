Feature: We want to be able to create anonymous contracts which do not have a contact


Scenario: The app should work with anonymous contracts
  Given I am an authorized user
    And There exists an anonymous contract with payments
  When I look at the interest page
  Then I should see the account movements
    And I should see the interest statement
  When I look at the interest transfer page
  Then I should see the interest statement
  When I look at the interest average page
  Then I should see the same interest as given by the one contract
  When I look at the expiring contracts page
  Then I should not see the contract

