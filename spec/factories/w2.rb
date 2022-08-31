FactoryBot.define do
  factory :w2 do
    intake
    legal_first_name { "Sheldon" }
    legal_last_name { "Faceplate" }
    sequence(:employee_ssn) { |n| "88811#{"%04d" % (n % 1000)}" }
    employee_street_address { "456 Somewhere Ave" }
    employee_city { "Cleveland" }
    employee_state { "OH" }
    employee_zip_code { "44092" }
    employer_ein { "123456789" }
    employer_name { "Code for America" }
    employer_street_address { "123 Main St" }
    employer_city { "San Francisco" }
    employer_state { "CA" }
    employer_zip_code { "94414" }
    wages_amount { 100.10 }
    federal_income_tax_withheld { 20.34 }
    standard_or_non_standard_code { "S" }
  end
end
