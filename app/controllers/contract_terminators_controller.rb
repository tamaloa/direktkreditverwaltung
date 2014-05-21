class ContractTerminatorsController < ApplicationController

  def new
    @contract_terminator = ContractTerminator.new(params[:id])

    respond_to do |format|
      format.html # new.html.erb
    end
  end


  def create
    @contract_terminator = ContractTerminator.new(params[:id], params[:contract_terminator])

    respond_to do |format|
      if @contract_terminator.valid? && @contract_terminator.terminate!
        format.html { redirect_to contract_path(@contract_terminator.contract),
                      notice: "Vertrag wurde erfolgreich aufgelöst. Bitte sofort die #{@contract_terminator.pay_back} überweisen" }
      else
        format.html { render action: "new" }
      end
    end
  end

 def destroy
    @contract_terminator = ContractTerminator.find(params[:id])
    @contract_terminator.destroy

    respond_to do |format|
      format.html { redirect_to contract_terminators_url }
    end
  end
end
