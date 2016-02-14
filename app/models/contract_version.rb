class ContractVersion < ActiveRecord::Base
  belongs_to :contract
  #TODO:Strong Params attr_accessible :duration_months,
  #                 :duration_years,
  #                 :notice_period,
  #                 :interest_rate,
  #                 :start,
  #                 :end_date,
  #                 :version

  validates_presence_of :interest_rate, :start, :version
  validate :sane_interest_rate

  def sane_interest_rate
    interest_form_input = interest_rate_before_type_cast.to_s
    errors.add(:interest_rate, 'Zinssatz ungültig. Eingabeformat z.B.: 1,5% als 0.015 eingeben') unless interest_form_input.match(/(\d)\.(\d)*/)
    interest = interest_rate.to_f
    errors.add(:interest_rate, 'Zinssatz ungültig. Muss zwischen 0 und 9% liegen.') unless (0.00 .. 0.09).cover?(interest)
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
