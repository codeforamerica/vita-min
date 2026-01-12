FactoryBot.define do
  factory :campaign_contact do
    sequence(:email_address) { |n| "person#{n}@example.com" }
    sequence(:sms_phone_number) { |n| "+1555000#{n.to_s.rjust(4, "0")}" }

    first_name { "Test" }
    last_name  { "User" }
    locale     { "en" }
    email_notification_opt_in { false }
    sms_notification_opt_in   { false }
    gyr_intake_ids { [] }
    sign_up_ids    { [] }
    state_file_intake_refs { [] }

    trait :email_opted_in do
      email_notification_opt_in { true }
      email_address { "opted_in@example.com" }
    end

    trait :sms_opted_in do
      sms_notification_opt_in { true }
      sms_phone_number { "+15551234567" }
    end

    trait :with_gyr_intake_ids do
      gyr_intake_ids { [1, 2] }
    end

    trait :with_sign_up_ids do
      sign_up_ids { [10, 11] }
    end

    trait :with_state_file_ref do
      state_file_intake_refs do
        [
          {
            "id" => 123,
            "type" => "StateFile::AzIntake",
            "state" => "AZ",
            "tax_year" => 2024
          }
        ]
      end
    end
  end
end
