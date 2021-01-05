FactoryBot.define do
  factory :coalition_lead_role do
    coalition { create(:coalition) }
  end
end
