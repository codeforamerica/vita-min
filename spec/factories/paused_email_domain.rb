FactoryBot.define do
  factory :paused_email_domain do
    sequence(:domain) { |n| "example#{n}.com" }

    paused_until { 1.hour.from_now }

    trait :expired do
      paused_until { 1.hour.ago }
    end

    trait :long_pause do
      paused_until { 7.days.from_now }
    end
  end
end