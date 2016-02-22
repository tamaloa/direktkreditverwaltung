class Contact < ActiveRecord::Base
  has_many :contracts, dependent: :destroy
end
