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
#  payer_name2                        :string
#  payer_name_control                 :string
#  payer_state_code                   :string
#  payer_state_identification_number  :string
#  payer_zip                          :string
#  phone_number                       :string
#  recipient_address_line1            :string
#  recipient_address_line2            :string
#  recipient_city_name                :string
#  recipient_name                     :string
#  recipient_ssn                      :string
#  recipient_state_code               :string
#  recipient_zip                      :string
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
class StateFile1099R < ApplicationRecord
  belongs_to :intake, polymorphic: true
  belongs_to :state_specific_followup, polymorphic: true, optional: true, dependent: :destroy

  encrypts :recipient_ssn

  # Not adding validations for fields we just copy over from the DF XML, since we have no recourse if they fail
  with_options on: :retirement_income_intake do
    validates :gross_distribution_amount, numericality: { greater_than: 0 }
    validates :state_distribution_amount,
              numericality: {
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: BigDecimal(10**10),
                allow_blank: true
              },
              presence: {
                message: proc { I18n.t('forms.errors.no_money_amount') }
              }
    validates :payer_state_identification_number, length: { maximum: 16 }
  end

  with_options on: [:income_review, :retirement_income_intake] do
    validate :less_than_gross_distribution, if: -> { gross_distribution_amount.present? }
    validates :state_tax_withheld_amount,
              numericality: {
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: BigDecimal(10**10),
                allow_blank: true
              },
              presence: {
                message: proc { I18n.t('forms.errors.no_money_amount') }
              }
  end

  def less_than_gross_distribution
    if state_tax_withheld_amount.present? && state_tax_withheld_amount > gross_distribution_amount
      errors.add(:state_tax_withheld_amount, I18n.t("activerecord.errors.models.state_file1099_r.errors.must_be_less_than_gross_distribution", gross_distribution_amount: gross_distribution_amount))
    end
  end
end
