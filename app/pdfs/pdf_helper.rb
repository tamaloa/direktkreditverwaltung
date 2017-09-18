module PdfHelper
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  private
  def company
    @company = Company.find :first
  end

end
