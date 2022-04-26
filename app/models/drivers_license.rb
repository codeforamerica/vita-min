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
#
class DriversLicense < ApplicationRecord
  has_one :intake
end
