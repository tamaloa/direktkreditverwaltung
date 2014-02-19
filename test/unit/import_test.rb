require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  test "importing contacts should work" do
    assert_difference 'Contact.count', 3 do
      Import.contacts("#{Rails.root}/test/fixtures/import/contacts.csv")
    end

  end

  test "importing contracts should work" do
    assert_difference 'Contract.count', 3 do
      Import.contracts("#{Rails.root}/test/fixtures/import/contracts.csv")
    end
  end

  test "importing contracts with credit donor linking should work" do
    Import.contacts("#{Rails.root}/test/fixtures/import/contacts.csv")
    Import.contracts("#{Rails.root}/test/fixtures/import/contracts.csv")
    ronja = Contact.where(prename: 'Ronja').first
    refute ronja.contracts.empty?
    projekt = Contact.where(name: 'Räuber GmbH').first
    refute projekt.contracts.empty?
  end

  test "importing with donor linking should warn if not sure enough" do
    2.times do
      Contact.create(name: 'Meier', prename: 'Frau')
    end

    assert_raise do
      Import.contracts("#{Rails.root}/test/fixtures/import/contracts.csv")
    end

  end


  test "importing contacts with structured address" do
    Import.contacts("#{Rails.root}/test/fixtures/import/contacts_with_structured_address.csv")
    ronja = Contact.where(prename: 'Ronja').first
    assert ronja.address.match(/Leipzig/)
    assert ronja.address.match(/04229/)
  end

end