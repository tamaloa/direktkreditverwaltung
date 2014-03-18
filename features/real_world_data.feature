Feature: The Direktkreditverwaltung should produce the same results as were calculated in previous years using
  the syndikat excel sheet for DKs

Scenario: Anonymized DK data for the year 2011
  Given The date is "2010-12-31"
    And DK contract 1 has a balance of 8852.58 euro and interest of 3.0%
    And DK contract 2 has a balance of 1644.23 euro and interest of 1.5%
    And DK contract 6 has a balance of 1526.11 euro and interest of 1.0%

  When Time passes
    And For DK contract 1 a deposit of 1000.00 euro is made on the "2011-01-17"
    And For DK contract 1 a deposit of 200.00 euro is made on the "2011-01-20"
    And For DK contract 1 a deposit of 200.00 euro is made on the "2011-02-09"
    And For DK contract 1 a payback of 500.00 euro is made on the "2011-01-13"
    And For DK contract 1 a payback of 400.00 euro is made on the "2011-03-04"
    And For DK contract 1 a payback of 600.00 euro is made on the "2011-07-13"
    And For DK contract 1 a deposit of 500.00 euro is made on the "2011-10-14"

    And For DK contract 6 a payback of 1526.11 euro is made on the "2011-05-26"
    And For DK contract 6 a payback of 6.11 euro is made on the "2011-05-26"
    #Actually 6.15 was payed back but that was miscalculated by human error (the sheet gives same result as above)


  Then Time passes and it is the "2011-12-31"
    And The balance including interest of DK contract 2 is 1668.89 euro
    And The balance including interest of DK contract 6 is 0.00 euro

    And The balance including interest of DK contract 1 is 9528.29 euro
    #If subtotals are not correctly rounded at all times this would be calculated as 9528.29

Scenario: Anonymized DK data for the year 2012
  Given The date is "2011-12-31"
    And DK contracts as described in "test/fixtures/data/dk-contracts_2012.csv" exist

  When Time passes
    And The deposits and paybacks as described in "test/fixtures/data/dk-movements_2012.csv" occur

  Then Time passes and it is the "2012-12-31"

  And The balance including interest of DK contract 1 is 9007.81 euro
  And The balance including interest of DK contract 2 is 1693.92 euro
  And The balance including interest of DK contract 9 is 2000.00 euro
  And The balance including interest of DK contract 10 is 1593.05 euro
  And The balance including interest of DK contract 11 is 3713.41 euro
  And The balance including interest of DK contract 14 is 2098.32 euro
  And The balance including interest of DK contract 15 is 10780.52 euro
  And The balance including interest of DK contract 16 is 10768.14 euro
  And The balance including interest of DK contract 17 is 10244.64 euro
  And The balance including interest of DK contract 18 is 3132.30 euro
  And The balance including interest of DK contract 20 is 5166.41 euro
  And The balance including interest of DK contract 21 is 3121.20 euro
  And The balance including interest of DK contract 22 is 2786.10 euro
  And The balance including interest of DK contract 23 is 10550.63 euro
  And The balance including interest of DK contract 27 is 50.00 euro
  And The balance including interest of DK contract 31 is 500.83 euro
  And The balance including interest of DK contract 32 is 180.15 euro
  And The balance including interest of DK contract 33 is 220.18 euro
  And The balance including interest of DK contract 34 is 140.12 euro
  And The balance including interest of DK contract 35 is 180.15 euro
  And The balance including interest of DK contract 3 is 2776.37 euro
  And The balance including interest of DK contract 4 is 1231.51 euro
  And The balance including interest of DK contract 5 is 895.01 euro
  And The balance including interest of DK contract 7 is 2270.01 euro
  And The balance including interest of DK contract 13 is 21051.56 euro
  And The balance including interest of DK contract 19 is 850.26 euro
  And The balance including interest of DK contract 24 is 691.91 euro
  And The balance including interest of DK contract 25 is 3592.75 euro
  And The balance including interest of DK contract 26 is 13213.78 euro
  And The balance including interest of DK contract 28 is 5000.56 euro
  And The balance including interest of DK contract 29 is 5000.67 euro
  And The balance including interest of DK contract 30 is 5000.83 euro



Scenario: Anonymized DK data for the year 2010
  Given The date is "2009-12-31"
    And DK contracts as described in "test/fixtures/data/dk-contracts_2010.csv" exist

  When Time passes
    And The deposits and paybacks as described in "test/fixtures/data/dk-movements_2010.csv" occur

  Then Time passes and it is the "2010-12-31"

  #8852.58 euro was miscalculated by human error (the sheet gives same result as above)
  And The balance including interest of DK contract 1 is 8906.25 euro
  And The balance including interest of DK contract 2 is 1644.23 euro
  And The balance including interest of DK contract 3 is 1036.07 euro
  And The balance including interest of DK contract 4 is 518.05 euro
  And The balance including interest of DK contract 5 is 0.00 euro
  And The balance including interest of DK contract 6 is 1526.11 euro
  And The balance including interest of DK contract 7 is 1154.71 euro
  And The balance including interest of DK contract 8 is 0.00 euro
  And The balance including interest of DK contract 9 is 2000.00 euro
  And The balance including interest of DK contract 10 is 1531.19 euro
  And The balance including interest of DK contract 11 is 3569.22 euro
  And The balance including interest of DK contract 12 is 3052.67 euro
  And The balance including interest of DK contract 13 is 10192.5 euro
  And The balance including interest of DK contract 14 is 2016.84 euro
  And The balance including interest of DK contract 15 is 10161.67 euro
  And The balance including interest of DK contract 16 is 10150.00 euro
  And The balance including interest of DK contract 17 is 10042.78 euro
  And The balance including interest of DK contract 18 is 3010.67 euro
  And The balance including interest of DK contract 19 is 576.55 euro

Scenario: Contracts with interest changes during the year
  Given The date is "2012-12-31"
    And DK contract 13 has a balance of 21051.56 euro and interest of 3.0%
    And DK contract 131 has a balance of 21052.40 euro and interest of 3.0%
  When Time passes
    And For DK contract 13 the interest changes to 2.0% on the "2013-07-01"
    And For DK contract 131 the interest changes to 2.0% on the "2013-07-01"
  Then Time passes and it is the "2013-12-31"
    And The balance including interest of DK contract 13 is 21577.86 euro
    And The balance including interest of DK contract 131 is 21578.70 euro
