class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_company

  private
  def load_company
    @company = Company.first_or_default #TODO this will be replaced by current_user.company some time later
  end

end
