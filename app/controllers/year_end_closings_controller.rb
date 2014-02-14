class YearEndClosingsController < ApplicationController


  def new
    @year_end_closing = YearEndClosing.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @year_end_closing = YearEndClosing.new(:year => params[:date][:year])

    respond_to do |format|
      if @year_end_closing.valid? && @year_end_closing.close_year!
        format.html { redirect_to new_year_end_closings_url,
                                  notice: "Jahresabschluss für #{@year_end_closing.year} durchgeführt" }
      else
        format.html { render action: "new" }
      end
    end
  end


end
