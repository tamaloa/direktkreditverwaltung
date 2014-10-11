class YearClosingStatementsController < ApplicationController
  def show
    year = params[:year].to_i
    contract = Contract.find_by_id(params[:id])
    @statement = YearClosingStatement.new(contract: contract, year: year)
    redirect_to :root unless @statement.valid?

    @statement
  end
end
