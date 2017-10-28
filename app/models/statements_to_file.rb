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

  def to_pdf(contract)
    statement = YearClosingStatement.new(contract: contract, year: year)
    pdf = PdfYearClosingStatement.new(statement)
    full_path = pdf_file_full_path(contract)
    pdf.render_file(full_path)
    full_path
  end

  def contract_full_path(contract)

  end

  def pdf_dir_path
    current_pdf_dir = "#{Rails.root}/pdfs/#{year}"
    Dir.mkdir(current_pdf_dir) unless Dir.exist?(current_pdf_dir)
    current_pdf_dir
  end

  def pdf_file_full_path(contract)
    current_pdf_dir = pdf_dir_path
    filename = "#{year}-DK_#{file_safe contract.number}-#{file_safe contract.contact.try(:name)}-Jahreskontoauszug.pdf"
    Shellwords.escape "#{current_pdf_dir}/#{filename}"
  end

  def zip_them_up
    @zip_file_name = "#{Rails.root}/pdfs/#{year_end_closing.year}_Alle-Jahrekontoauszüge.zip"
    directory = "#{Rails.root}/pdfs/#{year_end_closing.year}/"
    zip_options = '-r -X -j' #r - recursive; X - no extra fileatributes; j - no directories

    File.delete(@zip_file_name) if File.exist?(@zip_file_name)
    success = system "zip #{zip_options} #{zip_file_name} #{directory}"
    @zip_file_name if success
  end

  def zip_file
    File.open(@zip_file_name)
  end

  private

  def file_safe(string)
    string.to_s.gsub('ä','ae').gsub('ö','oe').gsub('ü','ue').gsub('ß','ss').
           gsub('Ä','Ae').gsub('Ö','Oe').gsub('Ü','ue').gsub(/\W/,'')
  end


end
