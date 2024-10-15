# == Schema Information
#
# Table name: state_file1099_rs
#
#  id                                 :bigint           not null, primary key
#  capital_gain_amount                :decimal(12, 2)
#  designated_roth_account_first_year :integer
#  distribution_code                  :string
#  federal_income_tax_withheld_amount :decimal(12, 2)
#  gross_distribution_amount          :decimal(12, 2)
#  intake_type                        :string           not null
#  payer_address_line1                :string
#  payer_address_line2                :string
#  payer_city_name                    :string
#  payer_identification_number        :string
#  payer_name                         :string
#  payer_name_control                 :string
#  payer_state_code                   :string
#  payer_state_identification_number  :string
#  payer_zip                          :string
#  phone_number                       :string
#  recipient_name                     :string
#  recipient_ssn                      :string
#  standard                           :boolean
#  state_code                         :string
#  state_distribution_amount          :decimal(12, 2)
#  state_specific_followup_type       :string
#  state_tax_withheld_amount          :decimal(12, 2)
#  taxable_amount                     :decimal(12, 2)
#  taxable_amount_not_determined      :boolean
#  total_distribution                 :boolean
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint           not null
#  state_specific_followup_id         :bigint
#
# Indexes
#
#  index_state_file1099_rs_on_intake                   (intake_type,intake_id)
#  index_state_file1099_rs_on_state_specific_followup  (state_specific_followup_type,state_specific_followup_id)
#
require 'rails_helper'

RSpec.describe StateFile1099R, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
