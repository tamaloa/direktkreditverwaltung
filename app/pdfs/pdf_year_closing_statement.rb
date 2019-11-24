class PdfYearClosingStatement < Prawn::Document
  include PdfHelper


  def initialize(statement)
    @statement = statement
    @contract = statement.contract
    @year = statement.year
    super(page_size: 'A4', top_margin: 30, left_margin: 55)

    font 'Helvetica'

    gmbh_adress = "#{company.gmbh_name}     #{company.street}     #{company.zip_code} #{company.city}"
    gmbh_mail = company.email
    gmbh_greet = "Die Finanz-Crew der #{company.gmbh_name}"
    kunet_adress = "#{company.verein_name}     #{company.street}     #{company.zip_code} #{company.city}"
    kunet_mail = "post@kuneterakete.de"
    kunet_greet = "Die Finanz-Crew des #{company.verein_name}"

    is_kunet_contract = @contract.number.index("70") == 0 ? true : false;
    company_adress = is_kunet_contract ? kunet_adress : gmbh_adress;
    company_mail = is_kunet_contract ? kunet_mail : gmbh_mail;
    farewell_formula = is_kunet_contract ? kunet_greet : gmbh_greet

    # set manually to true if contract was finished, shows sightly different text
    is_contract_finish = false; # default is: false

    postal_address_and_header(company_adress, company_mail)

    move_down 40

    text "#{company.city}, den #{DateTime.now.strftime("%d.%m.%Y")}", align: :right
    move_down 40
    text "Kontostand Nachrangdarlehen Nr. #{@contract.number}", size: 12, style: :bold
    move_down 30
    text "Hallo #{@contract.try(:contact).try(:prename)} #{@contract.try(:contact).try(:name)},"
    move_down 10
    if is_contract_finish
      text "herzlichen Dank für deine Unterstützung! Anbei der Kontoauszug und die Berechnung der Zinsen. " +
           "Auf Wunsch erstellen wir eine gesonderte Zinsbescheinigung für die Steuererklärung."
    else
      text "herzlichen Dank für die Unterstützung im Jahr #{@year}! Anbei der Kontoauszug und die Berechnung der Zinsen. " +
           "Auf Wunsch erstellen wir eine gesonderte Zinsbescheinigung für die Steuererklärung."
    end
    move_down 5
    text " Wir bitten um Überprüfung des Auszugs. " +
         "Falls etwas nicht stimmt oder unverständlich ist, stehen wir für Rückfragen gern zur Verfügung."
    move_down 5
    if !is_contract_finish
      text "Die Zinsen wurden auf dem Direktkreditkonto gutgeschrieben. Auf Wunsch zahlen wir diese auch gern aus." if @contract.add_interest_to_deposit_annually
    end
    move_down 10
    text "Buchungsübersicht", style: :bold
    move_down 5

    interest_calculation_table

    move_down 10
    if !is_contract_finish
      text "Kontostand zum Jahresabschluss #{ @year }: <b>#{ currency(@contract.balance(Date.new(@year, 12, 31))) }</b>", inline_format: true
    end
    move_down 15
    text "Wir werden die Zinsen in den nächsten Tagen auf das im Vertrag angegebene Konto überweisen." unless @contract.add_interest_to_deposit_annually
    text "Zinseinkünfte sind einkommensteuerpflichtig.", style: :bold, align: :center
    move_down 10
    text "Vielen Dank!"
    move_down 30
    text "Mit freundlichen Grüßen"
    text farewell_formula
    move_down 30

    is_kunet_contract ? nil : footer
  end

  def postal_address_and_header company_adress, company_mail
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
      if company.building_street && company.building_zipcode
        text company.building_street, size: 8
        text "#{company.building_zipcode} #{company.city}", size: 8
      else
        text company.street, size: 8
        text "#{company.zip_code} #{company.city}", size: 8
      end

      move_down 10
      text company_mail, size: 8 # kunet vs. gmbh
      text company.web, size: 8
    end

    bounding_box [0, y_pos - address_y_pos],
                 width: image_width do
      fill_color '777777'
      text company_adress, size: 7 # kunet vs. gmbh
      fill_color '000000'
      move_down 10
      text "#{@contract.contact.try(:prename)} #{@contract.contact.try(:name)}"
      address = @contract.contact.try(:address)
      if address
        address_array = address.split(',')
        (0..(address_array.length-2)).to_a.each do |i|
          text address_array[i]
        end
        text address_array.last
      end
    end
  end


  #TODO: Statement could use a method which return the following array of arrays for table rendering (Presenter)
  def interest_calculation_table
    data = [['Datum', 'Vorgang', 'Betrag', 'Zinssatz']]
    @statement.movements.each do |movement|
      unless movement[:type] == :movement && movement[:amount] < 0.0
        data << [
            movement[:date].strftime('%d.%m.%Y'),
            name_for_movement(movement),
            currency(movement[:amount].to_s),
            fraction(movement[:interest_rate])
        ]
      else
        data << [
            movement[:date].strftime('%d.%m.%Y'),
            name_for_movement(movement),
            currency(movement[:amount].to_s)
        ]
      end
    end

    # additional row for account balance at closing date
    closing_date = Date.new(@year, 12, 31)
    data << [closing_date.strftime('%d.%m.%Y'), "Saldo", "#{currency(@contract.balance(closing_date))}"]

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
