# == Schema Information
#
# Table name: w2s
#
#  id                                 :bigint           not null, primary key
#  box10_dependent_care_benefits      :decimal(12, 2)
#  box11_nonqualified_plans           :decimal(12, 2)
#  box12a_code                        :string
#  box12a_value                       :decimal(12, 2)
#  box12b_code                        :string
#  box12b_value                       :decimal(12, 2)
#  box12c_code                        :string
#  box12c_value                       :decimal(12, 2)
#  box12d_code                        :string
#  box12d_value                       :decimal(12, 2)
#  box13_retirement_plan              :integer          default("unfilled")
#  box13_statutory_employee           :integer          default("unfilled")
#  box13_third_party_sick_pay         :integer          default("unfilled")
#  box3_social_security_wages         :decimal(12, 2)
#  box4_social_security_tax_withheld  :decimal(12, 2)
#  box5_medicare_wages_and_tip_amount :decimal(12, 2)
#  box6_medicare_tax_withheld         :decimal(12, 2)
#  box7_social_security_tips_amount   :decimal(12, 2)
#  box8_allocated_tips                :decimal(12, 2)
#  box_d_control_number               :string
#  completed_at                       :datetime
#  creation_token                     :string
#  employee                           :integer          default("unfilled"), not null
#  employee_city                      :string
#  employee_state                     :string
#  employee_street_address            :string
#  employee_zip_code                  :string
#  employer_city                      :string
#  employer_ein                       :string
#  employer_name                      :string
#  employer_state                     :string
#  employer_street_address            :string
#  employer_zip_code                  :string
#  federal_income_tax_withheld        :decimal(12, 2)
#  intake_type                        :string
#  wages_amount                       :decimal(12, 2)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint
#
# Indexes
#
#  index_w2s_on_creation_token  (creation_token)
#  index_w2s_on_intake_id       (intake_id)
#
FactoryBot.define do
  factory :w2 do
    intake
    employee { 'primary' }
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
    completed_at { DateTime.now }
    box13_retirement_plan { 'no' }
    box13_statutory_employee { 'no' }
    box13_third_party_sick_pay { 'no' }
  end
end
