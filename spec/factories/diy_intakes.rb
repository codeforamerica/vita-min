# == Schema Information
#
# Table name: diy_intakes
#
#  id                        :bigint           not null, primary key
#  clicked_chat_with_us_at   :datetime
#  email_address             :string
#  email_notification_opt_in :integer          default("unfilled")
#  filing_frequency          :integer          default("unfilled")
#  hashed_email              :string
#  locale                    :string
#  preferred_first_name      :string
#  received_1099             :integer          default("unfilled"), not null
#  referrer                  :string
#  sms_notification_opt_in   :integer          default("unfilled")
#  sms_phone_number          :string
#  source                    :string
#  state_of_residence        :string
#  token                     :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visitor_id                :string
#
# Indexes
#
#  index_diy_intakes_on_hashed_email  (hashed_email)
#
FactoryBot.define do
  factory :diy_intake do
    trait :filled_out do
      locale { "es" }
      referrer { "https://www.gallopingacrosstheplains.horse/tax-help" }
      sequence(:email_address) { |n| "diy_intake_#{n}@example.com" }
      source { "horse-help" }
    end
  end
end
