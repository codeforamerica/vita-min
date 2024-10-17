# == Schema Information
#
# Table name: state_file_w2s
#
#  id                               :bigint           not null, primary key
#  employee_address_line_1          :string
#  employee_address_line_2          :string
#  employee_city                    :string
#  employee_name                    :string
#  employee_ssn                     :string
#  employee_state                   :string
#  employee_zip                     :string
#  employer_city                    :string
#  employer_ein                     :string
#  employer_name                    :string
#  employer_name_control_txt        :string
#  employer_state                   :string
#  employer_state_id_num            :string
#  employer_street_address          :string
#  employer_zip                     :string
#  local_income_tax_amount          :decimal(12, 2)
#  local_wages_and_tips_amount      :decimal(12, 2)
#  locality_nm                      :string
#  medicare_tax_withheld_amount     :string
#  medicare_wages_and_tips_amount   :string
#  other_deductions_benefits_amount :string
#  other_deductions_benefits_desc   :string
#  social_security_tax_amount       :string
#  social_security_wages_amount     :string
#  standard_or_nonstandard_code     :string
#  state_file_intake_type           :string
#  state_income_tax_amount          :decimal(12, 2)
#  state_wages_amount               :decimal(12, 2)
#  w2_index                         :integer
#  wages_amount                     :string
#  withholding_amount               :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  state_file_intake_id             :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
class StateFileW2 < ApplicationRecord
  self.ignored_columns = %w[state_wages_amt state_income_tax_amt local_wages_and_tips_amt local_income_tax_amt]

  include XmlMethods
  STATE_TAX_GRP_TEMPLATE = <<~XML
  <W2StateTaxGrp>
    <StateAbbreviationCd></StateAbbreviationCd>
    <EmployerStateIdNum></EmployerStateIdNum>
    <StateWagesAmt></StateWagesAmt>
    <StateIncomeTaxAmt></StateIncomeTaxAmt>
    <W2LocalTaxGrp>
      <LocalWagesAndTipsAmt></LocalWagesAndTipsAmt>
      <LocalIncomeTaxAmt></LocalIncomeTaxAmt>
      <LocalityNm></LocalityNm>
    </W2LocalTaxGrp>
  </W2StateTaxGrp>
  XML
  belongs_to :state_file_intake, polymorphic: true

  validates :w2_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :employer_state_id_num, format: { with: /\A(\d{0,17})\z/, message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.employer_state_id_error') } }
  validates :state_wages_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_wages_amount.present? }
  validates :state_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_income_tax_amount.present? }
  validates :local_wages_and_tips_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_wages_and_tips_amount.present? }
  validates :local_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_income_tax_amount.present? }
  validates :locality_nm, presence: { message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.locality_nm_missing_error') } }, if: -> { local_wages_and_tips_amount.present? && local_wages_and_tips_amount.positive? }
  validates :employer_state_id_num, presence: true, if: -> { state_wages_amount.present? && state_wages_amount.positive? }
  validates :locality_nm, format: { with: /\A[a-zA-Z]{1}([A-Za-z\-\s']{0,19})\z/, message: :only_letters }, if: -> { locality_nm.present? }
  validate :validate_tax_amts
  validate :state_specific_validation
  before_validation :locality_nm_to_upper_case

  encrypts :employee_ssn

  def state_specific_validation
    state_file_intake.validate_state_specific_w2_requirements(self) if state_file_intake.present?
  end

  def validate_tax_amts
    if (state_income_tax_amount || 0).positive? && (state_wages_amount || 0) <= 0
      errors.add(:state_wages_amount, I18n.t("state_file.questions.w2.edit.state_wages_amt_error"))
    end
    if (local_income_tax_amount || 0).positive? && (local_wages_and_tips_amount || 0) <= 0
      errors.add(:local_wages_and_tips_amount, I18n.t("state_file.questions.w2.edit.local_wages_and_tips_amt_error"))
    end
    if state_income_tax_amount.present? && state_wages_amount.present? && state_income_tax_amount > state_wages_amount
      errors.add(:state_income_tax_amount, I18n.t("state_file.questions.w2.edit.state_income_tax_amt_error"))
    end
    if local_income_tax_amount.present? && local_wages_and_tips_amount.present? && local_income_tax_amount > local_wages_and_tips_amount
      errors.add(:local_income_tax_amount, I18n.t("state_file.questions.w2.edit.local_income_tax_amt_error"))
    end
    w2 = state_file_intake.direct_file_data.w2s[w2_index]
    if w2.present?
      if state_income_tax_amount.present? && local_income_tax_amount.present? && (state_income_tax_amount + local_income_tax_amount > w2.WagesAmt)
        errors.add(:local_income_tax_amount, I18n.t("state_file.questions.w2.edit.wages_amt_error", wages_amount: w2.WagesAmt))
        errors.add(:state_income_tax_amount, I18n.t("state_file.questions.w2.edit.wages_amt_error", wages_amount: w2.WagesAmt))
      end
    end
  end

  def locality_nm_to_upper_case
    if locality_nm.present?
      self.locality_nm = locality_nm.upcase
    end
  end

  def state_tax_group_xml_node
    xml_template = Nokogiri::XML(STATE_TAX_GRP_TEMPLATE)
    xml_template.at(:StateAbbreviationCd).content = employer_state_id_num.present? ? state_file_intake.state_code.upcase : ""
    xml_template.at(:EmployerStateIdNum).content = employer_state_id_num
    xml_template.at(:StateWagesAmt).content = state_wages_amount&.round
    xml_template.at(:StateIncomeTaxAmt).content = state_income_tax_amount&.round
    xml_template.at(:LocalWagesAndTipsAmt).content = local_wages_and_tips_amount&.round
    xml_template.at(:LocalIncomeTaxAmt).content = local_income_tax_amount&.round
    xml_template.at(:LocalityNm).content = locality_nm
    delete_blank_nodes(xml_template)
    result = xml_template.at(:W2StateTaxGrp)
    result.nil? ? "" : result.to_xml
  end
end
