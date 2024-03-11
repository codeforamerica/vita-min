# == Schema Information
#
# Table name: state_file_w2s
#
#  id                       :bigint           not null, primary key
#  employer_state_id_num    :string
#  local_income_tax_amt     :integer
#  local_wages_and_tips_amt :integer
#  locality_nm              :string
#  state_file_intake_type   :string
#  state_income_tax_amt     :integer
#  state_wages_amt          :integer
#  w2_index                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  state_file_intake_id     :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
FactoryBot.define do
  factory :state_file_w2 do
    w2_index { 0 }
    employer_state_id_num { "12345" }
    state_wages_amt { 10000 }
    state_income_tax_amt { 350 }
    local_wages_and_tips_amt { 100 }
    local_income_tax_amt { 100 }
    locality_nm { "NYC" }
  end
end
