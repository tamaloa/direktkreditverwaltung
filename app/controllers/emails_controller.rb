class EmailsController < ApplicationController
  # GET /emails
  # GET /emails.json
  def index
    @year = params[:year]
    @mail_template = MailTemplate.find_or_create_by_year(@year)
    @test_email = Email.new(year: @year)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @emails }
    end
  end

  # GET /emails/1
  # GET /emails/1.json
  def show
    @email = Email.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email }
    end
  end

end
