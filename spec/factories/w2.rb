FactoryBot.define do
  factory :w2 do
    intake
    legal_first_name { "Sheldon" }
    legal_last_name { "Faceplate" }
    sequence(:employee_ssn) { |n| "88811#{"%04d" % (n % 1000)}" }
  end
end
