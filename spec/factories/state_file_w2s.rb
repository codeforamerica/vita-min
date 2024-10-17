# == Schema Information
#
# Table name: state_file_w2s
#
#  id                               :bigint           not null, primary key
#  employee_address_line_1          :string
#  employee_address_line_2          :string
#  employee_city                    :string
#  employee_name                    :string
#  employee_ssn                     :string
#  employee_state                   :string
#  employee_zip                     :string
#  employer_city                    :string
#  employer_ein                     :string
#  employer_name                    :string
#  employer_name_control_txt        :string
#  employer_state                   :string
#  employer_state_id_num            :string
#  employer_street_address          :string
#  employer_zip                     :string
#  local_income_tax_amount          :decimal(12, 2)
#  local_wages_and_tips_amount      :decimal(12, 2)
#  locality_nm                      :string
#  medicare_tax_withheld_amount     :string
#  medicare_wages_and_tips_amount   :string
#  other_deductions_benefits_amount :string
#  other_deductions_benefits_desc   :string
#  social_security_tax_amount       :string
#  social_security_wages_amount     :string
#  standard_or_nonstandard_code     :string
#  state_file_intake_type           :string
#  state_income_tax_amount          :decimal(12, 2)
#  state_wages_amount               :decimal(12, 2)
#  w2_index                         :integer
#  wages_amount                     :string
#  withholding_amount               :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  state_file_intake_id             :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
FactoryBot.define do
  factory :state_file_w2 do
    w2_index { 0 }
    employer_state_id_num { "12345" }
    state_wages_amount { 10000 }
    state_income_tax_amount { 350 }
    local_wages_and_tips_amount { 100 }
    local_income_tax_amount { 100 }
    locality_nm { "NYC" }
  end
end
