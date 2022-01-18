FactoryBot.define do
  factory :archived_2021_ctc_intake, class: Archived::Intake::CtcIntake2021 do
    preferred_name { "Cherry" }
    type { 'Intake::CtcIntake' }
    primary_first_name { "Cher" }
    association :client, factory: :ctc_client
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
  end

  factory :archived_2021_gyr_intake, class: Archived::Intake::GyrIntake2021 do
    preferred_name { "Cherry" }
    type { 'Intake::GyrIntake' }
    primary_first_name { "Cher" }
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
  end
end
