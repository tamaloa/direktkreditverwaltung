class ContractVersion < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :duration_months, :duration_years, :interest_rate, :start, :version

  validates_presence_of :interest_rate, :start, :version
  validate :sane_interest_rate

  def sane_interest_rate
    interest_form_input = interest_rate_before_type_cast.to_s
    errors.add(:interest_rate, 'Zinssatz ungültig. Eingabeformat z.B.: 1,5% als 0.015 eingeben') unless interest_form_input.match(/(\d)\.(\d)*/)
    interest = interest_rate.to_f
    errors.add(:interest_rate, 'Zinssatz ungültig. Muss zwischen 0 und 9% liegen.') unless (0.00 .. 0.09).cover?(interest)
  end

  def end_date
    end_date = start
    end_date = end_date >> duration_months.to_i
    end_date = end_date >> (duration_years.to_i * 12)
    end_date
  end
end
