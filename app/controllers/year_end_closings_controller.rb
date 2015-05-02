class YearEndClosingsController < ApplicationController


  def index
    @year_end_closings = YearEndClosing.all
    @new_year_end_closing = YearEndClosing.new
  end

  def create
    @year_end_closing = YearEndClosing.new(:year => params[:date][:year])

    respond_to do |format|
      if @year_end_closing.valid? && @year_end_closing.close_year!
        format.html { redirect_to year_end_closings_url,
                                  notice: "Jahresabschluss für #{@year_end_closing.year} durchgeführt" }
      else
        format.html { render action: "index" }
      end
    end
  end

  def show
    @year_end_closing = YearEndClosing.new(:year => params[:id])

    respond_to do |format|
      format.html
      format.csv { send_data(@year_end_closing.as_csv,
          :type => 'text/csv',
          :filename => "tabelle_jahresabschluss_#{@year_end_closing.year}.csv",
          :disposition => 'attachment'
        ) }
      format.zip { send_file StatementsToFile.new(@year_end_closing).write }
    end
  end

  def send_test_email
    year = params[:id].to_i
    Email.send_test_email(year, @company.email)

    redirect_to emails_url(year: year),
                notice: "Eine Testmail für #{year} wurden an #{@company.email} geschickt."
  end

  def send_emails

    year_end_closing = YearEndClosing.new(:year => params[:id])
    year_end_closing.email_all_closing_statements

    redirect_to emails_url(year: year_end_closing.year),
                notice: "Die Emails für #{year_end_closing.year} wurden erstellt."
  end

  def destroy
    @year_end_closing = YearEndClosing.new(:year => params[:id])

    respond_to do |format|
      if @year_end_closing.revert
        format.html { redirect_to year_end_closings_url,
                                  notice: "Jahresabschluss für #{@year_end_closing.year} wurde rückgängig gemacht" }
      else
        format.html { render action: "index" }
      end
    end
  end


end
