class ContractVersion < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :duration_months, 
                  :duration_years, 
                  :notice_period, 
                  :interest_rate, 
                  :start, 
                  :version

  validates_presence_of :interest_rate, :start, :version

  def interest_rate=(interest)
    interest = interest.to_f
    raise "Interest should be between 0.00 and 0.09" unless (0.00 .. 0.09).cover?(interest)
    write_attribute(:interest_rate, interest)
  end

  def end_date
    end_date = start
    end_date = end_date >> duration_months.to_i
    end_date = end_date >> (duration_years.to_i * 12)
    end_date
  end
end
