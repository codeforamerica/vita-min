FactoryBot.define do
  factory :user do
    provider { "idme" }
    uid { SecureRandom.hex }
    email { "gary.gardengnome@example.green" }
  end
end
