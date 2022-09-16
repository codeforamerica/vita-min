# == Schema Information
#
# Table name: w2s
#
#  id                            :bigint           not null, primary key
#  creation_token                :string
#  employee                      :integer          default("unfilled"), not null
#  employee_city                 :string
#  employee_state                :string
#  employee_street_address       :string
#  employee_street_address2      :string
#  employee_zip_code             :string
#  employer_city                 :string
#  employer_ein                  :string
#  employer_name                 :string
#  employer_state                :string
#  employer_street_address       :string
#  employer_street_address2      :string
#  employer_zip_code             :string
#  federal_income_tax_withheld   :decimal(12, 2)
#  standard_or_non_standard_code :string
#  wages_amount                  :decimal(12, 2)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  intake_id                     :bigint
#
# Indexes
#
#  index_w2s_on_creation_token  (creation_token)
#  index_w2s_on_intake_id       (intake_id)
#
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
