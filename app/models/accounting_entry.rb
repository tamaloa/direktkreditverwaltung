class AccountingEntry < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :amount, :date, :annually_closing_entry
  validates_presence_of :amount, :date
  validates_numericality_of :amount


  def name
    return "Zinsen" if annually_closing_entry
    return "Einzahlung" if amount > 0
    return "Auszahlung" if amount < 0
    return ""
  end

  def type
    return :annually_closing_entry if annually_closing_entry
    :movement
  end
  ###
  # TODO: Decide if it is worth coping with sqlite deficencies or simply switching to a proper default database
  ###
  #validate :no_end_of_year_closing_booking_exists_for_this_year
  #
  #private
  #def no_end_of_year_closing_booking_exists_for_this_year
  #  this_year = date.beginning_of_year..date.end_of_year
  #
  #  closing_entry = AccountingEntry.where(contract_id: contract_id).
  #                                where(annually_closing_entry: true).
  #                                where(date: this_year)
  #                                #sqlite is really bad and needs something like this
  #                                #where(["datetime(date) BETWEEN datetime(?) AND datetime(?)", date.beginning_of_year, date.end_of_year])
  #
  #  errors.add(:base, I18n.t('accounting_entry.contract_closed') unless closing_entry.blank?
  #end
end
