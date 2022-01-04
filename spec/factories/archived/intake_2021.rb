FactoryBot.define do
  factory :archived_2021_intake, class: Archived::Intake::CtcIntake2021 do
    preferred_name { "Cherry" }
    type { 'Intake::CtcIntake' }
    primary_first_name { "Cher" }
    sequence(:visitor_id) { |n| "visitor_id_#{n}" }
    needs_to_flush_searchable_data_set_at { 1.minute.ago }
  end
end
