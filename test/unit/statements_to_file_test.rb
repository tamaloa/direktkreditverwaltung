require 'test_helper'

class StatementsToFileTest < ActiveSupport::TestCase

  def setup
    @year_end_closing = YearEndClosing.new(year: 2012)
  end

  test "a single statement should be written as PDF file" do
    filename = 'alsdjflewjlfjwldkjflsdf'
    full_path = "#{Rails.root}/pdfs/#{@year_end_closing.year}/#{filename}"
    begin
      assert_nothing_raised do
        StatementsToFile.new(@year_end_closing).to_pdf(Contract.last, filename)
      end
      assert File.exists?(full_path)
    ensure
      File.delete(full_path) if File.exist?(full_path)
    end

  end

  test "a zip file should be created" do
    zip_file = "#{Rails.root}/pdfs/#{@year_end_closing.year}_Alle-Jahrekontoauszüge.zip"
    begin
      StatementsToFile.new(@year_end_closing).zip_them_up
        assert File.exists?(zip_file)
    ensure
        File.delete(zip_file) if File.exists?(zip_file)
    end
  end

  test "the zip file should contain all contracts for the current year" do
    pending
  end

  test "Statements should only be written for a closed year" do
    pending
  end

  test "the zip file should not contain statements for closed contracts (except in the year of closing)" do
    pending
  end
end