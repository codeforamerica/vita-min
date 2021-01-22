FactoryBot.define do
  factory :vita_partner_state do
    state { "CA" }
    vita_partner { build(:vita_partner) }
  end
end
