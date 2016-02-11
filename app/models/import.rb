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
        Rails.logger.debug "<Import::contracts> contract for contract_id '#{data[:contract_id]}' could not be found"
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
  # category, number, prename, name, amount, interest, start, end | duration_month | notice_period
  def self.contracts(file)
    CSV.foreach(file, :headers => true) do |row|
      data = cleaned_row(row)
      next if data.values.all?(&:blank?)

      interest = data[:interest].chomp('%').to_f/100 if data[:interest].match(/%/)
      interest = interest.to_f #results in 0.0 for anything invalid

      start = Date.parse(data[:start]) if data[:start]
      start = Time.now.to_date unless start.is_a?(Date)

      existing_contract = Contract.find_by_number(data[:number])
      if existing_contract
        Rails.logger.warn "<Import::contracts> Contract with number '#{data[:number]}' already exists. Skipped importing data entry: #{data}"
        next
      end

      end_date = Date.parse(data[:end]) if (data[:end] && data[:end].to_i != 0)
      end_date = nil unless end_date.is_a?(Date)
      if data[:notice_period] && (data[:notice_period].to_i != 0)
        notice_period = data[:notice_period].to_i
       else
        notice_period = nil
      end

      last_version_data = {
        :notice_period => notice_period,
        :duration_months => data[:duration_month] ? data[:duration_month].to_i : nil,
        :end_date => end_date
      }

      contract = Contract.create_with_balance!(data[:number], data[:amount], interest, start, last_version_data)
      contract.comment = data[:comment] if data[:comment]
      contract.category = data[:category] if data[:category]
      contract.save

      Rails.logger.debug "<Import::contracts> Created contract with number '#{contract.number}'"

      if data[:name]
        Rails.logger.debug "<Import::contracts> Owner given -> trying to find match in database for name '#{data[:name]}'"
        query = {name: data[:name]}
        query[:prename] = data[:prename] if data[:prename]
        possible_contacts = Contact.where(query)
        raise "<Import::contracts> Too many possible candidates for contract import: #{data.to_s}" if (possible_contacts.count > 1)
        contact = possible_contacts.first
        contract.contact = contact if contact
        contract.save! if contact
        Rails.logger.debug "<Import::contracts> Owner found in database: #{contact.try(:name)}" if contact
        unless contact
          Rails.logger.debug "<Import::contracts> No Owner found in database for: #{data[:name]}, creating new owner"
          make_address_if_stored_structured(data)
          contact = Contact.create(name: data[:name], prename: data[:prename], address: data[:address],
                                   email: data[:email], phone: data[:phone] )
          contract.contact = contact if contact
          contract.save! if contact
          Rails.logger.debug "<Import::contracts> Owner created: #{contact.try(:name)}" if contact
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