class StatementsToFile

  attr_accessor :zip_file_name, :year_end_closing, :year

  def initialize(year_end_closing)
    @year_end_closing = year_end_closing
    @year = year_end_closing.year
  end

  def write
    all_to_pdf
    zip_them_up
  end

  def all_to_pdf
    @year_end_closing.contracts.each do |contract|
      to_pdf contract
    end
  end

  def to_pdf(contract, filename=nil)
    statement = YearClosingStatement.new(contract: contract, year: year)

    current_pdf_dir = "#{Rails.root}/pdfs/#{year}"
    Dir.mkdir(current_pdf_dir) unless Dir.exist?(current_pdf_dir)

    pdf = PdfYearClosingStatement.new(statement)
    filename ||= "#{year}-DK_#{contract.number}-#{contract.contact.try(:name)}-Jahreskontoauszug.pdf"
    full_path = Shellwords.escape "#{current_pdf_dir}/#{filename}"

    pdf.render_file(full_path)
    full_path
  end

  def zip_them_up
    @zip_file_name = "#{Rails.root}/pdfs/#{year_end_closing.year}_Alle-Jahrekontoauszüge.zip"
    directory = "#{Rails.root}/pdfs/#{year_end_closing.year}/"
    zip_options = '-r -X -j' #r - recursive; X - no extra fileatributes; j - no directories

    File.delete(@zip_file_name) if File.exist?(@zip_file_name)
    success = system "zip #{zip_options} #{zip_file_name} #{directory}"
    return @zip_file_name if success
  end

  def zip_file
    File.open(@zip_file_name)
  end

end
