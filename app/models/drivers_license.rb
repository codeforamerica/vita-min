# == Schema Information
#
# Table name: drivers_licenses
#
#  id              :bigint           not null, primary key
#  expiration_date :date             not null
#  issue_date      :date             not null
#  license_number  :string           not null
#  state           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intakes_id      :bigint
#
# Indexes
#
#  index_drivers_licenses_on_intakes_id  (intakes_id)
#
class DriversLicense < ApplicationRecord
  belongs_to :intake
  has_one :client, through: :intake
end
