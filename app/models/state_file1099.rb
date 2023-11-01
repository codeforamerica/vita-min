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
class StateFile1099 < ApplicationRecord
  belongs_to :intake, polymorphic: true

  enum address_confirmation: { unfilled: 0, yes: 1, no: 2 }, _prefix: :address_confirmation
  enum payer_name_is_default: { unfilled: 0, yes: 1, no: 2 }, _prefix: :payer_name_is_default
  enum recipient: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :recipient

  def default_payer_name
    'NY Department of Labor'
  end
end
