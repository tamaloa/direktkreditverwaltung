class PdfInterestLetter < Prawn::Document
  include PdfHelper

  IMAGE_WITH = 180
  IMAGE_HEIGHT = 52
  ADDRESS_Y_POS = 110

  def initialize(contracts, year, view)
    super(page_size: 'A4', top_margin: 30, left_margin: 55)
    @contracts = contracts
    @year = year
    @view = view

    hash = YAML.load_file("#{Rails.root}/custom/text_snippets.yml")
    texts = HashWithIndifferentAccess.new(hash)

    font 'Helvetica'

    @contracts.each_with_index do |contract, index|
      interest, interest_calculation = contract.interest @year
      next if interest == 0
      start_new_page unless index == 0

      x_pos = bounds.width-IMAGE_WITH
      y_pos = cursor
      image "#{Rails.root}/custom/logo.png", at: [x_pos, y_pos], 
                                             width: IMAGE_WITH
      bounding_box [x_pos + 55, y_pos - IMAGE_HEIGHT], 
                   width: IMAGE_WITH do
        text "Projekt im Mietshäuser Syndikat", size: 8, style: :italic
        move_down 10
        text texts['street_no'], size: 8
        text "#{texts['zipcode']} #{texts['city']}", size: 8
        move_down 10
        text texts['email'], size: 8
        text texts['web'], size: 8
      end

      bounding_box [0, y_pos - ADDRESS_Y_POS], 
                   width: IMAGE_WITH do
        fill_color '777777'
        text "#{texts['gmbh_name']}     #{texts['street_no']}     #{texts['zipcode']} #{texts['city']}", size: 7
        fill_color '000000'
        move_down 10
        text "#{contract.contact.try(:prename)} #{contract.contact.try(:name)}"
        address = contract.contact.try(:address)
        if address
          address_array = address.split(',')
          (0..(address_array.length-2)).to_a.each do |i|
            text address_array[i]
          end
          move_down 10
          text address_array.last
        end
      end

      move_down 40

      text "#{texts['city']}, den #{DateTime.now.strftime("%d.%m.%Y")}", align: :right
      move_down 40
      text "Kontostand Direktkreditvertrag Nr. #{contract.number}", size: 12, style: :bold
      move_down 30
      text "Guten Tag #{contract.contact.try(:prename)} #{contract.contact.try(:name)},"
      move_down 10
      text "der Kontostand des Direktkreditvertrags Nr. #{contract.number} beträgt heute, am #{DateTime.now.strftime("%d.%m.%Y")} #{currency(contract.balance DateTime.now.to_date)}. Die Zinsen für das Jahr #{@year} berechnen sich wie folgt:"
      move_down 5

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
      move_down 10
      text "<b>Zinsen #{@year}:</b> #{currency(interest)}", inline_format: true
      move_down 15
      text "Wir werden die Zinsen in den nächsten Tagen auf das im Vertrag angegebene Konto überweisen." unless contract.add_interest_to_deposit_annually
      text "Bitte beachten Sie, dass Sie sich selbst um die Abführung von Kapitalertragssteuer und Solidaritätszuschlag kümmern sollten, da wir das nicht übernehmen können."
      move_down 10
      text "Vielen Dank!"
      move_down 30
      text "Mit freundlichen Grüßen"
      move_down 30
      text texts['your_name']
      text "für die #{texts['gmbh_name']}"
      move_down 30

      #footer
      y_pos = 25
      self.line_width = 0.5
      stroke_line [0, y_pos], [bounds.width, y_pos]
      fill_color '777777'
      y_pos -= 5
      bounding_box [20, y_pos], width: bounds.width/3.0 do
        text texts['bank_name'], size: 8
        text texts['bank_account_info'], size: 8
      end
      bounding_box [20 + bounds.width/3.0, y_pos], width: bounds.width/3.0 do
        text "Geschäftsführung", size: 8
        text texts['gmbh_executive_board'], size: 8
      end
      bounding_box [20 + 2*bounds.width/3.0, y_pos], width: bounds.width/3.0 do
        text "Registergericht: #{texts['gmbh_register_number']}", size: 8
        text "Steuernummer: #{texts['gmbh_tax_number']}", size: 8
      end
 
    end
  end
end
