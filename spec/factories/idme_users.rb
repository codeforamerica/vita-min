# == Schema Information
#
# Table name: idme_users
#
#  id                        :bigint           not null, primary key
#  birth_date                :string
#  city                      :string
#  consented_to_service      :integer          default("unfilled"), not null
#  consented_to_service_at   :datetime
#  consented_to_service_ip   :string
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :inet
#  email                     :string
#  email_notification_opt_in :integer          default("unfilled"), not null
#  encrypted_ssn             :string
#  encrypted_ssn_iv          :string
#  first_name                :string
#  is_spouse                 :boolean          default(FALSE)
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone_number              :string
#  provider                  :string
#  sign_in_count             :integer          default(0), not null
#  sms_notification_opt_in   :integer          default("unfilled"), not null
#  state                     :string
#  street_address            :string
#  uid                       :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  intake_id                 :bigint           not null
#
# Indexes
#
#  index_idme_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

FactoryBot.define do
  factory :idme_user do
    uid { SecureRandom.hex }
    email { "gary.gardengnome@example.green" }
    intake
  end
end
