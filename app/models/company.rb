class Company < ActiveRecord::Base

  def self.first_or_default
    return Company.first if Company.any?
    default_company
  end

  private

  def self.default_company
    Company.create!(
        name: "Projekt Name",
        gmbh_name: "Hausprojekt GmbH",
        verein_name: "Hausverein e.V.",

        street: "Musterstraße 23",
        zip_code: "12345",
        city: "Leipzig",
        email: "hausprojekt@syndikat.org",
        web: "http://www.hausprojekt.net",


        bank_name: "GLS-Bank",
        bank_account_info: "IBAN 238109840139879423",
        gmbh_executive_board: "Anna Arthur, Benni Besen",
        gmbh_register_number: "HRB 123456 B",
        gmbh_tax_number: "27/002/12345"
    )
  end
end
