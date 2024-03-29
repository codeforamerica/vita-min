# == Schema Information
#
# Table name: addresses
#
#  id                   :bigint           not null, primary key
#  city                 :string
#  record_type          :string
#  skip_usps_validation :boolean          default(FALSE)
#  state                :string
#  street_address       :string
#  street_address2      :string
#  urbanization         :string
#  zip_code             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  record_id            :bigint
#
# Indexes
#
#  index_addresses_on_record_type_and_record_id  (record_type,record_id)
#
class Address < ApplicationRecord
  belongs_to :record, polymorphic: true

  validates_presence_of :zip_code

  def to_s
    <<~ADDRESS
      #{urbanization} #{street_address} #{street_address2}
      #{city}, #{state} #{zip_code}
    ADDRESS
  end
end
