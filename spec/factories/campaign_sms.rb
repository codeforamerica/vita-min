# == Schema Information
#
# Table name: campaign_sms
#
#  id                  :bigint           not null, primary key
#  body                :text             not null
#  error_code          :string
#  event_data          :jsonb
#  message_name        :string           not null
#  scheduled_send_at   :datetime
#  sent_at             :datetime
#  to_phone_number     :string           not null
#  twilio_sid          :string
#  twilio_status       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#
# Indexes
#
#  index_campaign_sms_on_campaign_contact_id               (campaign_contact_id)
#  index_campaign_sms_on_message_name_and_to_phone_number  (message_name,to_phone_number) UNIQUE
#  index_campaign_sms_on_twilio_sid                        (twilio_sid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
FactoryBot.define do
  factory :campaign_sms do
    association :campaign_contact

    message_name { "start_of_season_outreach" }
    body { "Hi there!" }

    to_phone_number { campaign_contact.sms_phone_number || "+15550000001" }

    scheduled_send_at { 1.minute.from_now }
    sent_at { nil }

    twilio_sid { nil }
    twilio_status { "queued" }

    error_code { nil }
    event_data { {} }
  end
end
