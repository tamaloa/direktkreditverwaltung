class AccountingEntry < ActiveRecord::Base
  belongs_to :contract
  attr_accessible :amount, :date, :annually_closing_entry, :interest_entry, :contract
  validates_presence_of :amount, :date
  validates_numericality_of :amount

  validate :no_entries_before_contract_start
  validate :no_entries_for_closed_contract


  def name
    return "Zinsen" if interest_entry
    return "Einzahlung" if amount > 0
    return "Auszahlung" if amount < 0
    return ""
  end

  def type
    return :interest_entry if interest_entry
    :movement
  end

  private

  def no_entries_before_contract_start
    date_before_contract_start = contract.contract_versions.first.start > self.date
    errors.add(:base, I18n.t('accounting_entry.date_before_contract_start')) if date_before_contract_start
  end

  def no_entries_for_closed_contract
  this_year = date.beginning_of_year..date.end_of_year

  closing_entry = AccountingEntry.where(contract_id: contract_id).
                                 where(annually_closing_entry: true).
                                 where(date: this_year)
                                 #sqlite is really bad and needs something like this
                                 #where(["datetime(date) BETWEEN datetime(?) AND datetime(?)", date.beginning_of_year, date.end_of_year])

  errors.add(:base, I18n.t('accounting_entry.contract_closed')) unless closing_entry.blank?
  end
end
