class YearClosingStatementsController < ApplicationController
  def show

    year = params[:year].to_i
    contract = Contract.find_by_id(params[:id])
    @statement = YearClosingStatement.new(contract: contract, year: year)
    redirect_to :root unless @statement.valid?

    @statement

    respond_to do |format|
      format.html
      format.pdf { render_pdf and return }
    end
  end

  
  private

  def render_pdf
    @contract = @statement.contract
    @year = @statement.year
    pdf = PdfYearClosingStatement.new(@statement)
    filename = "#{@year}-DK_#{@contract.number}-#{@contract.contact.try(:name)}-Jahreskontoauszug.pdf"
    pdf.render_file("#{Rails.root}/pdfs/#{@year}/#{filename}")

    send_data pdf.render, filename: filename,
                          type: "application/pdf",
                          disposition: "inline"
  end
end
