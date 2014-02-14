require 'csv'

class Import

  def self.contacts(file)
    CSV.foreach(file, :headers => true) do |row|
      data = row.to_hash.with_indifferent_access
      next if data.values.all?(&:blank?)

      if data.has_key?(:street) || data.has_key?(:zip) || data.has_key?(:city)
        data[:address] = "#{data[:street]}, #{data[:zip]} #{data[:city]}"
        data.delete(:street)
        data.delete(:zip)
        data.delete(:city)
      end

      Contact.create!(data)
    end
  end

  def self.accounting_entries(file)
    CSV.foreach(file, :headers => true) do |row|
      contract = Contract.where(:number => row.to_hash["contract_id"]).first
      if !contract
        puts "contract for contract_id #{row.to_hash['contract_id']} could not be found"
        next
      end
      entry = AccountingEntry.new
      entry.contract = contract
      entry.amount = row.to_hash["amount"]
      entry.date = row.to_hash["date"]
      entry.save!
    end
  end

  ##
  # Headers:
  # category	number	prename	 name	amount	interest  start
  def self.contracts(file)
    CSV.foreach(file, :headers => true) do |row|
      data = row.to_hash.with_indifferent_access
      next if data.values.all?(&:blank?)

      interest = 0.0 if data[:interest].blank?
      interest = data[:interest].chomp('%').to_f/100 if data[:interest].match(/%/)

      start = Date.parse(data[:start]) if data[:start]
      start = Time.now unless start.is_a?(Date)

      contract = Contract.create_with_balance!(data[:number], data[:amount], interest, start)

      if data[:name]
        query = {name: data[:name]}
        query[:prename] = data[:prename] if data[:prename]
        possible_contacts = Contact.where(query)
        raise "Too many possible candidates for contract import #{data.to_s}" if (possible_contacts.count > 1)
        contact = possible_contacts.first
        contract.contact = contact if contact
        contract.save! if contact
      end

    end
  end


end