class PdfInterestOverview < Prawn::Document
  include PdfHelper

  def initialize(contracts, year, view)
    super(page_size: 'A4', top_margin: 60, left_margin: 55)
    @contracts = contracts
    @year = year
    @view = view

    font 'Times-Roman'

    text "Zinsen für das Jahr #{@year}", size: 16, style: :bold
    sum_interest = 0
    @contracts.each do |contract|
      interest, interest_calculation = contract.interest @year
      next if interest == 0
      move_down 20
      text "Direktkreditvertrag Nr. #{contract.number}, #{contract.contact.try(:prename)} #{contract.contact.try(:name)}", size: 14, style: :bold
      move_down 5
      text "<b>Kontostand #{DateTime.now.to_date}:</b> #{currency(contract.balance(DateTime.now.to_date))}", inline_format: true
      move_down 5
      text "Zinsberechnung #{@year}:", style: :bold
      data = [['Datum', 'Vorgang', 'Betrag', 'Zinssatz', 
               'verbleibende Tage im Jahr', 
               'verbleibender Anteil am Jahr', 'Zinsen']]
      interest_calculation.each do |entry|
        data << [entry[:date], entry[:name], currency(entry[:amount]),
                 fraction(entry[:interest_rate]), 
                 entry[:days_left_in_year],
                 fraction(entry[:fraction_of_year]),
                 currency(entry[:interest])]
      end
      table data do
        row(0).font_style = :bold
        columns(2..6).align = :right
        self.row_colors = ["EEEEEE", "FFFFFF"]
        self.cell_style = {size: 8}
        self.header = true
      end
      move_down 5
      text "<b>Zinsen #{@year}:</b> #{currency(interest)}", inline_format: true
      sum_interest += interest
    end

    move_down 10
    text "Summe Zinsen", size: 16, style: :bold
    text "#{currency(sum_interest)}"
  end
  
end
