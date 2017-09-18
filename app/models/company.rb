class Company < ActiveRecord::Base
  attr_accessible :bank_account_info,
                  :bank_name,
                  :city,
                  :email,
                  :gmbh_executive_board,
                  :gmbh_name,
                  :gmbh_register_number,
                  :gmbh_tax_number,
                  :name,
                  :street,
                  :verein_name,
                  :web,
                  :zip_code
end
