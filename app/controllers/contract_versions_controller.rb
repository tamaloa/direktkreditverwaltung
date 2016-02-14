
class ContractVersionsController < ApplicationController

  # GET /contract_versions
  # GET /contract_versions.json
  def index
    @contract_versions = ContractVersion.find(
                          :all, 
                          :include => [{:contract => :contact}], 
                          :order => ["contracts.number", "version"])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contract_versions }
    end
  end

  # GET /contract_versions/1
  # GET /contract_versions/1.json
  def show
    @contract_version = ContractVersion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contract_version }
    end
  end

  # GET /contract_versions/new
  # GET /contract_versions/new.json
  def new
    @contract = Contract.find(params[:contract_id])
    @contract_version = ContractVersion.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contract_version }
    end
  end

  # GET /contract_versions/1/edit
  def edit
    @contract_version = ContractVersion.find(params[:id])
    @contract = Contract.find(@contract_version.contract_id)
  end

  # POST /contract_versions
  # POST /contract_versions.json
  def create
    @contract = Contract.find(params[:contract_id])
    @contract_version = @contract.contract_versions.create(contract_version_params)

    respond_to do |format|
      if @contract_version.save
        format.html { redirect_to @contract_version, notice: 'Vertragsversion wurde erfolgreich erstellt.' }
        format.json { render json: @contract_version, status: :created, location: @contract_version }
      else
        format.html { render action: "new" }
        format.json { render json: @contract_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contract_versions/1
  # PUT /contract_versions/1.json
  def update
    @contract_version = ContractVersion.find(params[:id])

    respond_to do |format|
      if @contract_version.update_attributes(contract_version_params)
        format.html { redirect_to @contract_version, notice: 'Vertragsversion wurde erfolgreich aktualisiert.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contract_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contract_versions/1
  # DELETE /contract_versions/1.json
  def destroy
    @contract_version = ContractVersion.find(params[:id])
    @contract_version.destroy

    respond_to do |format|
      format.html { redirect_to contract_versions_url }
      format.json { head :no_content }
    end
  end

  private
  def contract_version_params
    params.require(:contract_version).permit(:version, :start, :interest_rate, :notice_period, :end_date,
                                             :duration_month, :duration_years )
  end
end
