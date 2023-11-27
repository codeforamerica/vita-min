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
#  recipient_state             :string
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
class StateFile1099G < ApplicationRecord
  belongs_to :intake, polymorphic: true
  before_save :update_conditional_attributes

  enum address_confirmation: { unfilled: 0, yes: 1, no: 2 }, _prefix: :address_confirmation
  enum had_box_11: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_box_11
  enum recipient: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :recipient

  validates_inclusion_of :had_box_11, in: ['yes', 'no'], message: -> (_object, _data) { I18n.t("errors.messages.blank") }

  def update_conditional_attributes
    if payer_name_is_default_yes?
      self.payer_name = nil
    end
    if address_confirmation_yes?
      self.recipient_city = nil
      self.recipient_state = nil
      self.recipient_street_address = nil
      self.recipient_zip = nil
    end
  end

  def recipient_name
    if recipient_primary?
      intake.primary.full_name
    elsif recipient_spouse?
      intake.spouse.full_name
    end
  end

  def default_payer_name
    if intake.is_a?(StateFileNyIntake)
      'NYS Department of Labor'
    elsif intake.is_a?(StateFileAzIntake)
      'AZ Department of Economic Security'
    end
  end
end
