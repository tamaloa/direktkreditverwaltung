module PdfHelper
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  private
  def company
    @company = Company.find(1)
  end

end
