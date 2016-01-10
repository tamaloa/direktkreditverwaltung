class ContractVersion < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :duration_months, 
                  :duration_years, 
                  :notice_period, 
                  :interest_rate, 
                  :start, 
                  :end_date,
                  :version

  validates_presence_of :interest_rate, :start, :version

  def interest_rate=(interest)
    interest = interest.to_f
    raise "Interest should be between 0.00 and 0.09" unless (0.00 .. 0.09).cover?(interest)
    write_attribute(:interest_rate, interest)
  end

  # wrap missing concept for fixed-term versus open-ended contract-versions
  # - fixed-term-contracts are specified by end_date, duration_months or duration_year
  # - open ended contracts are specified by a notice_period
  def is_open_ended
    return (end_date.blank? && duration_months.blank? && duration_years.blank?)
  end

  def calculate_end_date
    if end_date
      date = end_date
    else
      date = start
      date = date >> duration_months.to_i
      date = date >> (duration_years.to_i * 12)
    end
    date
  end
end
