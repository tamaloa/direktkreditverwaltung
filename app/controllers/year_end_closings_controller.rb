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
