class PdfYearClosingStatement < Prawn::Document
  include PdfHelper


  def initialize(statement)
    @statement = statement
    @contract = statement.contract
    @year = statement.year
    super(page_size: 'A4', top_margin: 30, left_margin: 55)

    # @view = view

    font 'Helvetica'

    # next if interest == 0
    # start_new_page unless index == 0

    postal_address_and_header

    move_down 40

    text "#{company.city}, den #{DateTime.now.strftime("%d.%m.%Y")}", align: :right
    move_down 40
    text "Kontostand Direktkreditvertrag Nr. #{@contract.number}", size: 12, style: :bold
    move_down 30
    text "Hallo #{@contract.try(:contact).try(:prename)} #{@contract.try(:contact).try(:name)},"
    move_down 10
    text "herzlichen Dank für die Unterstützung im Jahr #{@year}. Anbei der Kontoauszug und die Berechnung der Zinsen. " +
             "Auf Wunsch erstellen wir eine gesonderte Zinsbescheinigung für die Steuerklärung. Wir bitte um Überprüfung des Auszugs. " +
             "Falls etwas nicht stimmt oder unverständlich ist, stehen wir für Rückfragen gerne zur Verfügung."
    text "Die Zinsen wurden auf dem Direktkreditkonto gutgeschrieben." if @contract.add_interest_to_deposit_annually

    #text "der Kontostand des Direktkreditvertrags Nr. #{contract.number} beträgt heute, am #{DateTime.now.strftime("%d.%m.%Y")} #{currency(contract.balance DateTime.now.to_date)}. Die Zinsen für das Jahr #{@year} berechnen sich wie folgt:"
    move_down 5

    interest_calculation_table

    # %p= "Zinsen #{@statement.year}: #{currency(@statement.annual_interest)}"
    #
    # %p= "Kontostand zum Jahresabschluss #{ @statement.year }: #{ currency(@statement.balance_closing_of_year) }"

    move_down 10
    #text "Zinsen #{@year}: #{currency(interest)}", inline_format: true
    text "Kontostand zum Jahresabschluss #{ @year }: <b>#{ currency(@contract.balance(Date.new(@year, 12, 31))) }</b>", inline_format: true
    move_down 15
    text "Wir werden die Zinsen in den nächsten Tagen auf das im Vertrag angegebene Konto überweisen." unless @contract.add_interest_to_deposit_annually
    text "Zinseinkünfte sind einkommensteuerpflichtig.", style: :bold, align: :center
    move_down 10
    text "Vielen Dank!"
    move_down 30
    text "Mit freundlichen Grüßen"
    move_down 30
    text "Das Direktkredit Team der #{company.gmbh_name}"
    move_down 30

    footer

  end

  def postal_address_and_header
    image_width = 180
    image_heigth = 52
    address_y_pos = 110

    x_pos = bounds.width-image_width
    y_pos = cursor

    image_file = "#{Rails.root}/custom/logo.png"
    image(image_file, at: [x_pos, y_pos], width: image_width) if File.exists?(image_file)

    bounding_box [x_pos + 55, y_pos - image_heigth],
                 width: image_width do
      text company.name, size: 10
      text "Projekt im Mietshäuser Syndikat", size: 8, style: :italic
      move_down 10
      text company.street, size: 8
      text "#{company.zip_code} #{company.city}", size: 8
      move_down 10
      text company.email, size: 8
      text company.web, size: 8
    end

    bounding_box [0, y_pos - address_y_pos],
                 width: image_width do
      fill_color '777777'
      text "#{company.gmbh_name}     #{company.street}     #{company.zip_code} #{company.city}", size: 7
      fill_color '000000'
      move_down 10
      text "#{@contract.contact.try(:prename)} #{@contract.contact.try(:name)}"
      address = @contract.contact.try(:address)
      if address
        address_array = address.split(',')
        (0..(address_array.length-2)).to_a.each do |i|
          text address_array[i]
        end
        move_down 10
        text address_array.last
      end
    end
  end


  #TODO: Statement could use a method which return the following array of arrays for table rendering (Presenter)
  def interest_calculation_table
    data = [['Datum', 'Vorgang', 'Betrag', 'Zinssatz', 'Zinsen']]
    @statement.movements.each do |movement|
      data << [
          movement[:date],
          name_for_movement(movement),
          currency(movement[:amount].to_s),
          fraction(movement[:interest_rate]),
          currency(movement[:interest])
      ]
    end

    table data do
      row(0).font_style = :bold
      columns(2..6).align = :right
      self.row_colors = ["EEEEEE", "FFFFFF"]
      self.cell_style = {size: 8}
      self.header = true
    end
  end

  def footer
    #footer
    y_pos = 25
    self.line_width = 0.5
    stroke_line [0, y_pos], [bounds.width, y_pos]
    fill_color '777777'
    y_pos -= 5
    bounding_box [20, y_pos], width: bounds.width/3.0 do
      text company.bank_name, size: 8
      text company.bank_account_info, size: 8
    end
    bounding_box [20 + bounds.width/3.0, y_pos], width: bounds.width/3.0 do
      text "Geschäftsführung", size: 8
      text company.gmbh_executive_board, size: 8
    end
    bounding_box [20 + 2*bounds.width/3.0, y_pos], width: bounds.width/3.0 do
      text "Registergericht: #{company.gmbh_register_number}", size: 8
      text "Steuernummer: #{company.gmbh_tax_number}", size: 8
    end
  end

  private
  def texts
    hash = YAML.load_file("#{Rails.root}/custom/text_snippets.yml")
    HashWithIndifferentAccess.new(hash)
  end

end
