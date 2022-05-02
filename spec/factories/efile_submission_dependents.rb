
FactoryBot.define do
  factory :efile_submission_dependent do
    efile_submission
    dependent
    qualifying_child { true }
    qualifying_ctc { true }
    qualifying_relative { false }
    age_during_tax_year { 12 }
  end
end
