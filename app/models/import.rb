require 'csv'

class Import

  def self.contacts(file)
    CSV.foreach(file, :headers => true) do |row|
      data = cleaned_row(row)
      next if data.values.all?(&:blank?)
      make_address_if_stored_structured(data)

      Contact.create!(data)
    end
  end

  def self.accounting_entries(file)
    CSV.foreach(file, :headers => true) do |row|
      data = cleaned_row(row)
      contract = Contract.where(:number => data[:contract_id]).first
      if !contract
        Rails.logger.debug "contract for contract_id #{data[:contract_id]} could not be found"
        next
      end
      entry = AccountingEntry.new
      entry.contract = contract
      entry.amount = data[:amount]
      entry.date = data[:date]
      entry.save!
    end
  end

  ##
  # Headers:
  # category	number	prename	 name	amount	interest  start
  def self.contracts(file)
    CSV.foreach(file, :headers => true) do |row|
      data = cleaned_row(row)
      next if data.values.all?(&:blank?)

      interest = 0.0 if data[:interest].blank?
      interest = data[:interest].chomp('%').to_f/100 if data[:interest].match(/%/)

      start = Date.parse(data[:start]) if data[:start]
      start = Time.now.to_date unless start.is_a?(Date)

      existing_contract = Contract.find_by_number(data[:number])
      Rails.logger.debug "You are trying to import a contract with an already existing number, skipped #{data}" and next if existing_contract
      contract = Contract.create_with_balance!(data[:number], data[:amount], interest, start)
      contract.comment = data[:comment] if data[:comment]
      contract.category = data[:category] if data[:category]
      contract.save

      Rails.logger.debug "Contract created #{contract.number}"

      if data[:name]
        Rails.logger.debug "Owner given, trying to find match in database: #{data[:name]}"
        query = {name: data[:name]}
        query[:prename] = data[:prename] if data[:prename]
        possible_contacts = Contact.where(query)
        raise "Too many possible candidates for contract import #{data.to_s}" if (possible_contacts.count > 1)
        contact = possible_contacts.first
        contract.contact = contact if contact
        contract.save! if contact
        Rails.logger.debug "Owner found in database: #{contact.try(:name)}" if contact
        unless contact
          Rails.logger.debug "No Owner found in database for: #{data[:name]}, creating new owner"
          make_address_if_stored_structured(data)
          contact = Contact.create(name: data[:name], prename: data[:prename], address: data[:address],
                                   email: data[:email], phone: data[:phone] )
          contract.contact = contact if contact
          contract.save! if contact
          Rails.logger.debug "Owner created: #{contact.try(:name)}" if contact
          end
      end

    end
  end

  private

  def self.cleaned_row(row)
    hashed_row = row.to_hash.with_indifferent_access
    hashed_row.values.each{|value| value.try(:squish!)}
    hashed_row
  end

  def self.make_address_if_stored_structured(data)
    if data.has_key?(:street) || data.has_key?(:zip) || data.has_key?(:city)
        data[:address] = "#{data[:street]}, #{data[:zip]} #{data[:city]}"
        data.delete(:street)
        data.delete(:zip)
        data.delete(:city)
    end
  end

end