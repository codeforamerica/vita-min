# == Schema Information
#
# Table name: state_file_w2s
#
#  id                       :bigint           not null, primary key
#  employer_state_id_num    :string
#  local_income_tax_amt     :integer
#  local_wages_and_tips_amt :integer
#  locality_nm              :string
#  state_file_intake_type   :string
#  state_income_tax_amt     :integer
#  state_wages_amt          :integer
#  w2_index                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  state_file_intake_id     :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
class StateFileW2 < ApplicationRecord
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

  validates :employer_state_id_num, format: { with: /\A(\d*)\z/ }, length: {maximum: 16}
  validates :state_wages_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { state_wages_amt.present? }
  validates :state_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { state_income_tax_amt.present? }
  validates :local_wages_and_tips_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { local_wages_and_tips_amt.present? }
  validates :local_income_tax_amt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { local_income_tax_amt.present? }
  validates :locality_nm, presence: { message: -> (_object, _data) { I18n.t('state_file.questions.ny_w2.edit.locality_nm_missing_error') } }, if: -> { local_wages_and_tips_amt.present? && local_wages_and_tips_amt.positive? }
  validates :employer_state_id_num, presence: true, if: -> { state_wages_amt.present? && state_wages_amt.positive? }
  validates :locality_nm, format: { with: /\A[a-zA-Z]{1}([A-Za-z\-\s']{0,19})\z/ }, if: -> { locality_nm.present? }
  validate :validate_tax_amts
  validate :locality_nm_validation
  before_validation :locality_nm_to_upper_case

  def locality_nm_validation
    return unless locality_nm.present?
    unless state_file_intake_type.constantize.locality_nm_valid?(locality_nm)
      errors.add(:locality_nm, I18n.t("state_file.questions.ny_w2.edit.locality_nm_error"))
    end
  end

  def validate_tax_amts
    if (state_income_tax_amt || 0).positive? && (state_wages_amt || 0) <= 0
      errors.add(:state_wages_amt, I18n.t("state_file.questions.ny_w2.edit.state_wages_amt_error"))
    end
    if (local_income_tax_amt || 0).positive? && (local_wages_and_tips_amt || 0) <= 0
      errors.add(:local_wages_and_tips_amt, I18n.t("state_file.questions.ny_w2.edit.local_wages_and_tips_amt_error"))
    end
    if state_income_tax_amt.present? && state_wages_amt.present? && state_income_tax_amt > state_wages_amt
      errors.add(:state_income_tax_amt, I18n.t("state_file.questions.ny_w2.edit.state_income_tax_amt_error"))
    end
    if local_income_tax_amt.present? && local_wages_and_tips_amt.present? && local_income_tax_amt > local_wages_and_tips_amt
      errors.add(:local_income_tax_amt, I18n.t("state_file.questions.ny_w2.edit.local_income_tax_amt_error"))
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
    xml_template.at(:StateWagesAmt).content = state_wages_amt
    xml_template.at(:StateIncomeTaxAmt).content = state_income_tax_amt
    xml_template.at(:LocalWagesAndTipsAmt).content = local_wages_and_tips_amt
    xml_template.at(:LocalIncomeTaxAmt).content = local_income_tax_amt
    xml_template.at(:LocalityNm).content = locality_nm

    result = xml_template.at(:W2StateTaxGrp)
    delete_blank_nodes(result)
    result.to_xml
  end
end
