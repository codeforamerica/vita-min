FactoryBot.define do
  factory :doc_assessment_feedback do
    association :doc_assessment
    association :user

    feedback { :unfilled }
    feedback_notes { nil }

    trait :correct do
      feedback { :correct }
    end

    trait :incorrect do
      feedback { :incorrect }
    end
  end
end