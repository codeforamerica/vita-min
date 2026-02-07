FactoryBot.define do
  factory :campaign_email do
    association :campaign_contact

    message_name { "preseason_outreach" }
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
