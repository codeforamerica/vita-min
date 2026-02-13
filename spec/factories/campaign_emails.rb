# == Schema Information
#
# Table name: campaign_emails
#
#  id                  :bigint           not null, primary key
#  error_code          :string
#  event_data          :jsonb
#  from_email          :string
#  mailgun_status      :string           default("created"), not null
#  message_name        :string
#  scheduled_send_at   :datetime
#  sent_at             :datetime
#  subject             :text
#  to_email            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#  mailgun_message_id  :string
#
# Indexes
#
#  index_campaign_emails_on_campaign_contact_id          (campaign_contact_id)
#  index_campaign_emails_on_contact_id_and_message_name  (campaign_contact_id,message_name) UNIQUE
#  index_campaign_emails_on_mailgun_message_id           (mailgun_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
FactoryBot.define do
  factory :campaign_email do
    association :campaign_contact

    message_name { "start_of_season_outreach" }
    to_email { "test@example.com" }
    from_email { "noreply@example.com" }
    subject { "Test subject" }

    mailgun_status { "created" }
    scheduled_send_at { nil }
    sent_at { nil }

    error_code { nil }
    event_data { {} }
    mailgun_message_id { SecureRandom.uuid }

    to_create do |instance|
      CampaignEmail.skip_callback(:create, :after, :deliver)
      begin
        instance.save!
      ensure
        CampaignEmail.set_callback(:create, :after, :deliver)
      end
    end

    trait :with_delivery do
      to_create(&:save!)
    end

    trait :scheduled do
      scheduled_send_at { 30.minutes.from_now }
    end

    trait :failed do
      mailgun_status { "failed" }
    end

    trait :delivered do
      mailgun_status { "delivered" }
      sent_at { Time.current }
    end
  end
end
