And(/^I view the interest page for all contracts for the year (\d+)$/) do |year|
  @current_year = year.to_i
  visit "/contracts/interest?year=#{year}"
end

Then(/^I see the DK contract (\d+) initial balance of (\d+\.\d+) euro$/) do |contract, euros|
  assert page.has_content?("#{@current_year}-01-01 	Saldo 	#{currency(euros.to_f)}")
end

And(/^I see the DK contract (\d+) deposit of (\d+\.\d+) euro$/) do |contract, euros|
  assert page.has_content?("Einzahlung 	#{currency(euros.to_f)}")
end

And(/^I do not see the DK contract (\d+) interest of (\d+\.\d+) euro$/) do |contract, euros|
  assert !page.has_content?("#{@current_year}-12-31 	Zinsen 	#{currency(euros.to_f)}")
end

When(/^I perform the year end closing for (\d+)$/) do |year|
  YearEndClosing.new(year: year.to_i).close_year!
end

Then(/^I see the DK contract (\d+) interest of (\d+\.\d+) euro$/) do |contract, euros|
  assert page.has_content?("#{@current_year}-12-31 	Zinsen 	#{currency(euros.to_f)}")
end