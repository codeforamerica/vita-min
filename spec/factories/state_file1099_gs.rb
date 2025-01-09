# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                                 :bigint           not null, primary key
#  address_confirmation               :integer          default("unfilled"), not null
#  federal_income_tax_withheld_amount :decimal(12, 2)
#  had_box_11                         :integer          default("unfilled"), not null
#  intake_type                        :string           not null
#  payer_city                         :string
#  payer_name                         :string
#  payer_street_address               :string
#  payer_tin                          :string
#  payer_zip                          :string
#  recipient                          :integer          default("unfilled"), not null
#  recipient_city                     :string
#  recipient_state                    :string
#  recipient_street_address           :string
#  recipient_street_address_apartment :string
#  recipient_zip                      :string
#  state_identification_number        :string
#  state_income_tax_withheld_amount   :decimal(12, 2)
#  unemployment_compensation_amount   :decimal(12, 2)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint           not null
#
# Indexes
#
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  factory :state_file1099_g do
    recipient { 'primary' }
    had_box_11 { 'yes' }
    address_confirmation {'no'}
    payer_name {'Business'}
    payer_street_address {'123 Main St'}
    payer_city {'New York'}
    payer_zip {'11102'}
    payer_tin {'270293117'}
    state_identification_number {'123456789'}
    unemployment_compensation_amount { '1' }
    federal_income_tax_withheld_amount { '0' }
    state_income_tax_withheld_amount { 0.0 }
    recipient_city {'New York'}
    recipient_street_address {'123 Recipient St'}
    recipient_zip {'11102'}
  end
end
