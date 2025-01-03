# == Schema Information
#
# Table name: state_file_w2s
#
#  id                          :bigint           not null, primary key
#  box14_fli                   :decimal(12, 2)
#  box14_stpickup              :decimal(12, 2)
#  box14_ui_hc_wd              :decimal(12, 2)
#  box14_ui_wf_swf             :decimal(12, 2)
#  employee_name               :string
#  employee_ssn                :string
#  employer_ein                :string
#  employer_name               :string
#  employer_state_id_num       :string
#  local_income_tax_amount     :decimal(12, 2)
#  local_wages_and_tips_amount :decimal(12, 2)
#  locality_nm                 :string
#  state_file_intake_type      :string
#  state_income_tax_amount     :decimal(12, 2)
#  state_wages_amount          :decimal(12, 2)
#  w2_index                    :integer
#  wages                       :decimal(12, 2)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  state_file_intake_id        :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
class StateFileW2 < ApplicationRecord
  attr_accessor :check_box14_limits
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
  encrypts :employee_ssn

  validates :w2_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :employer_state_id_num, length: { maximum: 16, message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.employer_state_id_error') } }
  validates :state_wages_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_wages_amount.present? }
  validates :state_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_income_tax_amount.present? }
  validates :local_wages_and_tips_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_wages_and_tips_amount.present? }
  validates :local_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_income_tax_amount.present? }
  validates :box14_fli, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_fli.present? }
  validates :box14_stpickup, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_stpickup.present? }
  validates :box14_ui_hc_wd, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_ui_hc_wd.present? }
  validates :box14_ui_wf_swf, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_ui_wf_swf.present? }
  validates :wages, numericality: { greater_than_or_equal_to: 0 }, if: -> { wages.present? }
  validates :locality_nm, presence: { message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.locality_nm_missing_error') } }, if: -> { local_wages_and_tips_amount.present? && local_wages_and_tips_amount.positive? }
  validates :employer_state_id_num, presence: true, if: -> { state_wages_amount.present? && state_wages_amount.positive? }
  validates :employer_ein, presence: true, format: { with: /\A[0-9]{9}\z/, message: ->(*_args) { I18n.t('validators.ein') } }
  validates :locality_nm, format: { with: /\A[a-zA-Z]{1}([A-Za-z\-\s']{0,19})\z/, message: :only_letters }, if: -> { locality_nm.present? }
  validate :validate_box14_limits, if: :check_box14_limits
  validate :validate_tax_amts
  validate :state_specific_validation
  before_validation :locality_nm_to_upper_case

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

  def get_box14_ui_overwrite
    read_attribute(:box14_ui_wf_swf) || box14_ui_hc_wd
  end

  private

  def validate_box14_limits
    validate_limit(:box14_ui_wf_swf, 179.78)
    validate_limit(:box14_fli, 145.26)
  end

  def validate_limit(field, limit)
    value = send(field)
    if value.present? && value > limit
      errors.add(field, I18n.t("validators.dollar_limit", limit: '%.2f' % limit))
    end
  end
end
