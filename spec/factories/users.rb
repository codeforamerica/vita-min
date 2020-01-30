# == Schema Information
#
# Table name: users
#
#  id             :bigint           not null, primary key
#  birth_date     :string
#  city           :string
#  email          :string
#  first_name     :string
#  last_name      :string
#  phone_number   :string
#  provider       :string
#  ssn            :string
#  state          :string
#  street_address :string
#  uid            :string
#  zip_code       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  intake_id      :bigint           not null
#
# Indexes
#
#  index_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

FactoryBot.define do
  factory :user do
    provider { "idme" }
    uid { SecureRandom.hex }
    email { "gary.gardengnome@example.green" }
    intake { create :intake }
  end
end
