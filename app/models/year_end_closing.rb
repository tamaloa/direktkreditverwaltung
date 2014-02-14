class YearEndClosing
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :year

  validates :year, presence: true
  validates :year, :numericality => true

  def initialize(attributes = {})
    @year = attributes[:year] || Time.now.prev_year.year
  end


  def close_year!
    Contract.where(:add_interest_to_deposit_annually => true).all.each do |contract|
      contract.year_end_closing!
    end
  end


  def persisted?
    false
  end

end
