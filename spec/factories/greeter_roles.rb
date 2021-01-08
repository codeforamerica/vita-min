FactoryBot.define do
  factory :greeter_role do
    coalition { create(:coalition) }
    organization { create(:organization) }
  end
end
