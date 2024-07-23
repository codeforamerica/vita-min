FactoryBot.define do
  factory :az322_contribution do
    date_of { Date.new(2023, 3, 4) }
    ctds_code { "100206038" }
    school_name { "Schublic Pool" }
    district_name { "Dool Schistrict" }
    amount { 300 }
  end
end
