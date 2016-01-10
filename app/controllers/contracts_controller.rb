class ContractsController < ApplicationController
  # GET /contracts
  # GET /contracts.json
  def index
    @contracts = Contract.active.all
    @terminated_contracts = Contract.terminated.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contracts }
    end
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
    @contract = Contract.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contract }
    end
  end

  # GET /contracts/new
  # GET /contracts/new.json
  def new
    @contact = Contact.find(params[:contact_id])
    @contract = Contract.new
    @new_contract_dummy = OpenStruct.new(
                          {:start => Date.today,
                           :duration_years => "",
                           :duration_months => "",
                           :end_date => nil,
                           :interest_rate => "",
                           :notice_perdiod => ""})

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contract }
    end
  end

  # GET /contracts/1/edit
  def edit
    @contract = Contract.find(params[:id])
    @contact = Contact.find(@contract.contact_id)
  end

  # POST /contracts
  # POST /contracts.json
  def create
    @contact = Contact.find(params[:contact_id])
    @contract = @contact.contracts.create(params[:contract])
    last_version = ContractVersion.new
    last_version.version = 1
    last_version.contract_id = @contract.id
    prepare_last_version(last_version, params)
    last_version.save

    respond_to do |format|
      if @contract.save
        format.html { redirect_to @contract, notice: 'Der Vertrag wurde erfolgreich erstellt' }
        format.json { render json: @contract, status: :created, location: @contract }
      else
        format.html { render action: "new" }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contracts/1
  # PUT /contracts/1.json
  def update
    @contract = Contract.find(params[:id])
    last_version = @contract.last_version
    prepare_last_version(last_version, params)
    last_version.save

    respond_to do |format|
      if @contract.update_attributes(params[:contract])
        format.html { redirect_to @contract, notice: 'Der Vertrag wurde erfolgreich aktualisiert.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  def prepare_last_version(contract_version, params)
    new_start = params[:last_version_start]
    contract_version.start = Date.new(new_start["(1i)"].to_i, 
                                  new_start["(2i)"].to_i, 
                                  new_start["(3i)"].to_i)
    
    new_end = params[:last_version_end_date]
    if new_end["(1i)"].eql?("") || new_end["(2i)"].eql?("") || new_end["(3i)"].eql?("")
      contract_version.end_date = nil
    else
      contract_version.end_date = Date.new(new_end["(1i)"].to_i, 
                                           new_end["(2i)"].to_i, 
                                           new_end["(3i)"].to_i)
    end
    
    contract_version.duration_months = params[:last_version_duration_months]
    contract_version.duration_years = params[:last_version_duration_years]
    contract_version.interest_rate = params[:last_version_interest_rate]
    contract_version.notice_period = params[:last_version_notice_period]
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy

    respond_to do |format|
      format.html { redirect_to contracts_url }
      format.json { head :no_content }
    end
  end

  # GET /contracts/interest
  def interest
    params[:year] ||= DateTime.now.year
    @contracts = []
    if params[:contract]
      @contracts = [params[:contract]]
    elsif
      @contracts = Contract.order(:number)      
    end
    @year = params[:year].to_i

    if params[:output] && params[:output].index("latex") == 0
      if params[:output] == "latex_overview"
        render "interest_overview.latex" and return
      elsif params[:output] == "latex_interest_letter"
        render "interest_letter.latex", :layout => "letter" and return
      elsif params[:output] == "latex_thanks_letter"
        render "thanks_letter.latex", :layout => "a5note" and return
      end
    elsif params[:output] && params[:output].index("pdf") == 0
      if params[:output] == "pdf_overview"
        render_pdf(PdfInterestOverview) and return
      elsif params[:output] == "pdf_interest_letter"
        render_pdf(PdfInterestLetter) and return
      elsif params[:output] == "pdf_thanks_letter"
        render_pdf(PdfInterestThanks) and return
      end
    end

    respond_to do |format|
      format.html 
      format.json { render json: @contracts }
    end
  end

  def render_pdf klass
    pdf = klass.new(@contracts, @year, view_context)
    single = @contracts.length == 1 ? "_#{@contracts.first.number}" : ""
    send_data pdf.render, filename: "#{klass.to_s}_#{@year}_contract#{single}.pdf", 
                          type: "application/pdf",
                          disposition: "inline"
  end

  # GET /contracts/interest_transfer_list
  def interest_transfer_list
    params[:year] ||= DateTime.now.year
    @contracts = Contract.order(:number)      
    @year = params[:year].to_i

    respond_to do |format|
      format.html 
      format.json { render json: @contracts }
    end
  end
  
  # GET /contracts/interest_average
  def interest_average
    @contracts = Contract.order(:number)      

    respond_to do |format|
      format.html 
      format.json { render json: @contracts }
    end
  end

  # GET /contracts/expiring
  def expiring
    # get all contracts with specified duration and determine expiring date
    contracts_with_duration = Contract.all.select{ |c| c.last_version.duration_months ||
                                                       c.last_version.duration_years }
    contracts_with_duration.each do |contract|
      last_version = contract.last_version
      duration_in_month = last_version.duration_months || last_version.duration_years * 12
      contract.expiring = duration_in_month.months.since(last_version.start)
    end

    # get alle contracts with specified end_date and set expiring date
    contracts_with_end_date = Contract.all.select{ |c| c.last_version.end_date }
    contracts_with_end_date.each do |contract|
      contract.expiring = contract.last_version.end_date
    end

    # merge both
    @contracts = (contracts_with_duration.concat(contracts_with_end_date)).sort_by(&:expiring)

    respond_to do |format|
      format.html # expiring.html.erb
      format.json { render json: @contracts }
    end
  end

  # GET /contracts/remaining_term
  def remaining_term
    params[:year] ||= DateTime.now.year
    @year = params[:year].to_i
    # determine contracts with account_entries relevant for year
    @contracts = Contract.all_with_remaining_month(@year)
    respond_to do |format|
      format.html # remaining_term.html.erb
    end
  end
end
