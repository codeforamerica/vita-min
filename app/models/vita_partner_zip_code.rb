# == Schema Information
#
# Table name: vita_partner_zip_codes
#
#  id              :bigint           not null, primary key
#  zip_code        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_vita_partner_zip_codes_on_vita_partner_id  (vita_partner_id)
#  index_vita_partner_zip_codes_on_zip_code         (zip_code) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class VitaPartnerZipCode < ApplicationRecord
  belongs_to :vita_partner
  validate :record_of_zip_code
  validates :zip_code, uniqueness: true

  def city_state
    ZipCodes.details(zip_code)[:name]
  end

  private

  def record_of_zip_code
    errors.add(:zip_code, "#{zip_code} is not a valid US zip code.") unless ZipCodes.has_key?(zip_code)
  end
end
