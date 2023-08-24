FactoryBot.define do
  factory :drivers_license do
    license_number { "NUM12345" }
    state { "OH" }
    issue_date { Date.new(2020, 11, 11) }
    expiration_date { Date.new(2024, 11, 11) }
  end
end
