class DriversLicense < ApplicationRecord
  belongs_to :intake
  has_one :client, through: :intake
end
