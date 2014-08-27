Feature: The interest statement of each contract should show the initial balance, deposits, withdrawals and interest
  for a year.

Scenario: Showing a contracts correct balance
  Given I am an authorized user
    And The date is "2012-12-31"
    And DK contract 1111 has a balance of 1000.00 euro and interest of 1.0%
    And For DK contract 1111 a deposit of 500.00 euro is made on the "2013-01-01"
  When Time passes and it is the "2013-12-31"
    And I view the interest page for all contracts for the year 2013
  Then I see the DK contract 1111 initial balance of 1000.00 euro
    And I see the DK contract 1111 deposit of 500.00 euro
    And I do not see the DK contract 1111 interest of 15.00 euro
  When I perform the year end closing for 2013
    And I view the interest page for all contracts for the year 2013
  Then I see the DK contract 1111 interest of 15.00 euro

  Scenario: Using the PDF output to view interest letters
    Given I am an authorized user
    When I view the interest PDF for all contracts for the year 2013
    Then I see the DK contract 9899 initial balance of 5000.00 euro
      And I do not see the DK contract 9899 interest of 100.00 euro
    When I perform the year end closing for 2013
      And I view the interest PDF for all contracts for the year 2013
    Then I see the DK contract 9899 interest of 100.00 euro