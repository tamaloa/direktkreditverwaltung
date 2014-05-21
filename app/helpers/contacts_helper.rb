module ContactsHelper
  def contact_short(contact)
    return 'no contact' unless contact
    contact_line = contact.name
    contact_line << ", #{contact.prename}" unless contact.prename.blank?
    contact_line
  end

  def contact_long(contact)
    contact_line = contact_short(contact)
    contact_line << " (#{contact.email}" unless contact.email.blank?
    contact_line << " [#{contact.address}]" unless contact.address.blank?
    contact_line
  end
end
