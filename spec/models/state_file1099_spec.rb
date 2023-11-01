# == Schema Information
#
# Table name: state_file1099s
#
#  id                          :bigint           not null, primary key
#  address_confirmation        :integer          default("unfilled"), not null
#  federal_income_tax_withheld :integer
#  intake_type                 :string           not null
#  payer_name                  :string
#  payer_name_is_default       :integer          default("unfilled"), not null
#  recipient                   :integer          default("unfilled"), not null
#  recipient_city              :string
#  recipient_state             :string
#  recipient_street_address    :string
#  recipient_zip               :string
#  state_income_tax_withheld   :integer
#  unemployment_compensation   :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint           not null
#
# Indexes
#
#  index_state_file1099s_on_intake  (intake_type,intake_id)
#
require 'rails_helper'

RSpec.describe StateFile1099, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
