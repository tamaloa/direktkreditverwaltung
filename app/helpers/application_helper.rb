# encoding: utf-8
module ApplicationHelper
  def currency value
    number_to_currency(value, :locale => :de)
  end

  def latex_currency value
    number_to_currency(value, :locale => :de).gsub("€","\\euro")
  end

  def fraction value
    return '-' unless value.is_a?(Numeric)
    number_to_percentage(value * 100)
  end

  def name_for_movement(movement)
    return "Saldo" if movement[:type] == :initial_balance
    return "Zinsen" if movement[:type] == :annually_closing_entry
    return "Einzahlung" if movement[:type] == :movement && movement[:amount] > 0.0
    return "Auszahlung" if movement[:type] == :movement && movement[:amount] < 0.0
  end
end
