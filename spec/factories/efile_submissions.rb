FactoryBot.define do
  factory :efile_submission do
    tax_return

    trait :preparing do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :preparing, efile_submission: submission)
      end
    end

    trait :queued do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :queued, efile_submission: submission)
      end
    end

    trait :transmitted do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :transmitted, efile_submission: submission)
      end
    end

    trait :failed do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :failed, efile_submission: submission)
      end
    end

    trait :rejected do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :rejected, efile_submission: submission)
      end
    end

    trait :accepted do
      after(:create) do |submission|
        FactoryGirl.create(:efile_submission_transition, :accepted, efile_submission: submission)
      end
    end
  end
end
