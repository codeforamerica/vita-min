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
#  zip_code             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  record_id            :bigint
#
# Indexes
#
#  index_addresses_on_record_type_and_record_id  (record_type,record_id)
#
FactoryBot.define do
  factory :address do
    record { efile_submission }
    street_address { "23627 HAWKINS CREEK CT" }
    zip_code { "77494" }
    state { "TX" }
    city { "KATY" }
  end
end
