class AccountingEntriesController < ApplicationController
  # GET /accounting_entries
  # GET /accounting_entries.json
  def index

    if params[:year]
      start_time = Date.new(params[:year].to_i, 1, 1)
      end_time = Date.new(params[:year].to_i, 12, 31)
    elsif params[:start_date] && params[:end_date]
      start_time = Date.new(params[:start_date][:year].to_i,
                            params[:start_date][:month].to_i,
                            params[:start_date][:day].to_i)
      end_time = Date.new(params[:end_date][:year].to_i,
                          params[:end_date][:month].to_i,
                          params[:end_date][:day].to_i)
    end
    if params[:contract_id]
      @accounting_entries = AccountingEntry.where(:contract_id => params[:contract_id]).order(:date)
    elsif start_time && end_time
      @accounting_entries = AccountingEntry.where(:date => start_time..end_time).order(:date)
    else
      @accounting_entries = AccountingEntry.order(:date)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accounting_entries }
    end
  end

  # GET /accounting_entries/1
  # GET /accounting_entries/1.json
  def show
    @accounting_entry = AccountingEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @accounting_entry }
    end
  end

  # GET /accounting_entries/new
  # GET /accounting_entries/new.json
  def new
    @contract = Contract.find(params[:contract_id])
    @accounting_entry = AccountingEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @accounting_entry }
    end
  end

  # GET /accounting_entries/1/edit
  def edit
    @accounting_entry = AccountingEntry.find(params[:id])
    @contract = Contract.find(@accounting_entry.contract_id)
  end

  # POST /accounting_entries
  # POST /accounting_entries.json
  def create
    @contract = Contract.find(params[:contract_id])
    @accounting_entry = @contract.accounting_entries.create(params[:accounting_entry])

    respond_to do |format|
      if @accounting_entry.save
        format.html { redirect_to @accounting_entry, notice: 'Die Buchung wurde erfolgreich aktualisiert.' }
        format.json { render json: @accounting_entry, status: :created, location: @accounting_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @accounting_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_entries/1
  # PUT /accounting_entries/1.json
  def update
    @accounting_entry = AccountingEntry.find(params[:id])

    respond_to do |format|
      if @accounting_entry.update_attributes(params[:accounting_entry])
        format.html { redirect_to @accounting_entry, notice: 'Accounting entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @accounting_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_entries/1
  # DELETE /accounting_entries/1.json
  def destroy
    @accounting_entry = AccountingEntry.find(params[:id])
    @accounting_entry.destroy

    respond_to do |format|
      format.html { redirect_to accounting_entries_url }
      format.json { head :no_content }
    end
  end
end
