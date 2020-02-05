# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  birth_date         :string
#  city               :string
#  current_sign_in_at :datetime
#  current_sign_in_ip :inet
#  email              :string
#  first_name         :string
#  is_spouse          :boolean          default(FALSE)
#  last_name          :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :inet
#  phone_number       :string
#  provider           :string
#  sign_in_count      :integer          default(0), not null
#  ssn                :string
#  state              :string
#  street_address     :string
#  uid                :string
#  zip_code           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  intake_id          :bigint           not null
#
# Indexes
#
#  index_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

class User < ApplicationRecord
  devise :omniauthable, :trackable, omniauth_providers: [:idme]
  belongs_to :intake

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      # this only runs on initialize
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = auth.info.email
      user.birth_date = auth.info.birth_date
      user.phone_number = auth.info.phone
      user.ssn = auth.info.social
      user.street_address = auth.info.street
      user.city = auth.info.city
      user.state = auth.info.state
      user.zip_code = auth.info.zip_code
    end
  end
end
