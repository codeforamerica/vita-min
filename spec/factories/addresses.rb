FactoryBot.define do
  factory :address do
    record { efile_submission }
    street_address { "23627 HAWKINS CREEK CT" }
    zip_code { "77494" }
    state { "TX" }
    city { "KATY" }
  end
end