# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                          :bigint           not null, primary key
#  address_confirmation        :integer          default("unfilled"), not null
#  federal_income_tax_withheld :integer
#  had_box_11                  :integer          default("unfilled"), not null
#  intake_type                 :string           not null
#  payer_city                  :string
#  payer_name                  :string
#  payer_street_address        :string
#  payer_tin                   :string
#  payer_zip                   :string
#  recipient                   :integer          default("unfilled"), not null
#  recipient_city              :string
#  recipient_street_address    :string
#  recipient_zip               :string
#  state_identification_number :string
#  state_income_tax_withheld   :integer
#  unemployment_compensation   :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint           not null
#
# Indexes
#
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  factory :state_file1099_g do
    had_box_11 { 'yes' }
    payer_name {'Business'}
    payer_street_address {'123 Main St'}
    payer_city {'New York'}
    payer_zip {'11102'}
    payer_tin {'123456789'}
    state_identification_number {'123456789'}
  end
end
