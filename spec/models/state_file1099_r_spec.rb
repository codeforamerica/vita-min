# == Schema Information
#
# Table name: state_file1099_rs
#
#  id                                 :bigint           not null, primary key
#  capital_gain_amount                :integer          not null
#  designated_roth_account_first_year :integer          not null
#  distribution_code                  :string           not null
#  federal_income_tax_withheld_amount :integer          not null
#  gross_distribution_amount          :integer          not null
#  payer_address_line1                :string           not null
#  payer_address_line2                :string           not null
#  payer_city_name                    :string           not null
#  payer_identification_number        :string           not null
#  payer_name                         :string           not null
#  payer_name_control                 :string           not null
#  payer_state_code                   :string           not null
#  payer_state_identification_number  :string           not null
#  payer_zip                          :string           not null
#  phone_number                       :string           not null
#  recipient_name                     :string           not null
#  recipient_ssn                      :string           not null
#  standard                           :boolean          not null
#  state_code                         :string           not null
#  state_distribution_amount          :integer          not null
#  state_tax_withheld_amount          :integer          not null
#  taxable_amount                     :integer          not null
#  taxable_amount_not_determined      :boolean          not null
#  total_distribution                 :boolean          not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
require 'rails_helper'

RSpec.describe StateFile1099R, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
