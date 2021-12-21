FactoryBot.define do
  factory :state_routing_target do
    target { build :organization }
  end
end
