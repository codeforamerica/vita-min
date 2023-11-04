# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                          :bigint           not null, primary key
#  address_confirmation        :integer          default("unfilled"), not null
#  federal_income_tax_withheld :integer
#  had_box_11                  :integer          default("unfilled"), not null
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
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
class StateFile1099G < ApplicationRecord
  belongs_to :intake, polymorphic: true

  enum address_confirmation: { unfilled: 0, yes: 1, no: 2 }, _prefix: :address_confirmation
  enum had_box_11: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_box_11
  enum payer_name_is_default: { unfilled: 0, yes: 1, no: 2 }, _prefix: :payer_name_is_default
  enum recipient: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :recipient

  validates_inclusion_of :had_box_11, in: ['yes', 'no'], message: -> (_object, _data) { I18n.t("errors.messages.blank") }

  def recipient_name
    if recipient_primary?
      intake.primary.full_name
    elsif recipient_spouse?
      intake.spouse.full_name
    end
  end

  def default_payer_name
    if intake.is_a?(StateFileNyIntake)
      'NY Department of Labor'
    elsif intake.is_a?(StateFileAzIntake)
      'AZ Department of Economic Security'
    end
  end
end
