And(/^I view the interest page for all contracts for the year (\d+)$/) do |year|
  @current_year = year.to_i
  visit "/contracts/interest?year=#{year}"
end
When(/^I view the interest PDF for all contracts for the year (\d+)$/) do |year|
  @current_year = year.to_i
  visit "/contracts/interest?year=#{year}&output=pdf_interest_letter"
  @pdf_received = true
  pdf_as_one_big_string = PDF::Inspector::Text.analyze(page.body).strings
  page.driver.response.instance_variable_set('@body', pdf_as_one_big_string) #does not work :/
  page.instance_variable_set(:@body, pdf_as_one_big_string)
end

Then(/^I see the DK contract (\d+) initial balance of (\d+\.\d+) euro$/) do |contract, euros|
  pending if @pdf_received #TODO: parsing pdfs is very unreliable (i.e. breaks on travis)

  assert page.has_content?("#{@current_year}-01-01Saldo#{currency(euros.to_f)}") if @pdf_received
  assert page.has_content?("#{@current_year}-01-01 	Saldo 	#{currency(euros.to_f)}") unless @pdf_received
end

And(/^I see the DK contract (\d+) deposit of (\d+\.\d+) euro$/) do |contract, euros|
  assert page.has_content?("Einzahlung 	#{currency(euros.to_f)}")
end
Then(/^I (.+) the DK contract (\d+) interest of (\d+\.\d+) euro$/) do |seen, contract, euros|
  pending if @pdf_received #TODO: parsing pdfs is very unreliable (i.e. breaks on travis)

  visible = seen.eql?("do not see") ? false : true
  content_present = page.has_content?("#{@current_year}-12-31Zinsen#{currency(euros.to_f)}") if @pdf_received
  content_present = page.has_content?("#{@current_year}-12-31 	Zinsen 	#{currency(euros.to_f)}") unless @pdf_received
  assert content_present if visible
  assert !content_present unless visible
end

When(/^I perform the year end closing for (\d+)$/) do |year|
  YearEndClosing.new(year: year.to_i).close_year!
end

