require 'csv'

namespace :import do

  desc "import contacts from csv file"
  #column headers should be: name prename address account_number bank_number bank_name email phone remark (not all columns are needed)
  task :contacts, [:file] => :environment do |t, args|
    file = args[:file]
    if !file
      puts "parameter 'file' needs to be given" 
      next 
    end

    Import.contacts(file)

  end

  desc "import contracts with initial balance from csv file"
  # Headers:
  # category	number	prename	 name	amount	interest  start
  task :contacts, [:file] => :environment do |t, args|
    file = args[:file]
    if !file
      puts "parameter 'file' needs to be given"
      next
    end

    Import.contracts(file)

  end

  desc "import accounting_entries from csv file"
  #column headers should be: date amount contract_id
  #format of date should be YYYY-MM-DD
  #format of amount should be n.nn 
  task :accounting_entries, [:file] => :environment do |t, args|
    file = args[:file]
    if !file
      puts "parameter 'file' needs to be given" 
      next 
    end

    Import.accounting_entries(file)

  end

  desc "contract2contractversion"
  task :contract_versions => :environment do
      contracts = Contract.all
      contracts.each do |contract|
          contract_version = ContractVersion.new
          contract_version.contract = contract
          contract_version.version = 1
          contract_version.start = contract.start
          contract_version.duration_months = contract.duration_month
          contract_version.duration_years = contract.duration_years
          contract_version.interest_rate = contract.interest_rate
          contract_version.save
      end
  end
end




