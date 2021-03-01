# encoding: utf-8
module ApplicationHelper
  def currency value
    number_to_currency(value, :locale => :de)
  end

  def fraction value
    return '-' unless value.is_a?(Numeric)
    number_to_percentage(value * 100)
  end

  def name_for_movement(movement)
    return "Saldo" if movement[:type] == :initial_balance
    return "Zinsen" if movement[:type] == :interest_entry
    return "End-Saldo" if movement[:type] == :final_balance
    return "Einzahlung" if movement[:type] == :movement && movement[:amount] > 0.0
    return "Auszahlung" if movement[:type] == :movement && movement[:amount] < 0.0
    return "Zinsen bisher" if movement[:type] == :sum_of_previous_interests
  end
end
