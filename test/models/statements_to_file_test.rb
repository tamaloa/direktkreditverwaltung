require 'test_helper'

class StatementsToFileTest < ActiveSupport::TestCase

  def setup
    @year_end_closing = YearEndClosing.new(year: 2500)
    @year_end_closing.close_year!
    @statements_to_file = StatementsToFile.new(@year_end_closing)
  end

  test "a single statement should be written as PDF file" do
    filename = ''
    begin
      assert_nothing_raised do
        filename = @statements_to_file.to_pdf(Contract.last)
      end
      assert File.exists?(filename)
    ensure
      File.delete(filename) if File.exist?(filename)
    end

  end

  test "filenames should be escaped properly" do
    invalid_contact = Contact.first
    invalid_contact.update_attribute(:name, 'Irgendwer /co invalid due to slash')
    contract = invalid_contact.contracts.first
    filename = @statements_to_file.pdf_file_full_path(contract)
    assert_nothing_raised do
      begin
        StatementsToFile.new(@year_end_closing).to_pdf(contract)
      ensure
        File.delete(filename) if File.exist?(filename)
      end
    end
  end

  test "a zip file should be created" do
    zip_file = ''
    begin
      @statements_to_file.all_to_pdf
      zip_file = @statements_to_file.zip_them_up
      assert zip_file
      assert File.exists?(zip_file)
    ensure
        File.delete(zip_file) if File.exists?(zip_file)
        FileUtils.remove_dir(@statements_to_file.pdf_dir_path)
    end
  end

  test "the zip file should contain all contracts for the current year" do
    skip
  end

  test "Statements should only be written for a closed year" do
    skip
  end

  test "the zip file should not contain statements for closed contracts (except in the year of closing)" do
    skip
  end
end