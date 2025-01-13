FactoryBot.define do
  factory :state_file_archived_intake_request do
    email_address { "geddy_lee@gmail.com" }
    failed_attempts { 0 }
    locked_at { nil }

    trait :locked do
      locked_at { 5.minutes.ago }
    end
  end
end
