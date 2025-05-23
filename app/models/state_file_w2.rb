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
  include SubmissionBuilder::FormattingMethods
  attr_accessor :check_box14_limits

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

  with_options on: [:state_file_edit, :state_file_income_review] do
    validates :employer_state_id_num, length: { maximum: 16, message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.employer_state_id_error') } }
    validates :state_wages_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_wages_amount.present? }
    validates :state_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { state_income_tax_amount.present? }
    validates :local_wages_and_tips_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_wages_and_tips_amount.present? && StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code) }
    validates :local_income_tax_amount, numericality: { greater_than_or_equal_to: 0 }, if: -> { local_income_tax_amount.present? && StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code) }
    validates :box14_fli, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_fli.present? }
    validates :box14_stpickup, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_stpickup.present? }
    validates :box14_ui_hc_wd, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_ui_hc_wd.present? }
    validates :box14_ui_wf_swf, numericality: { greater_than_or_equal_to: 0 }, if: -> { box14_ui_wf_swf.present? }
    validates :wages, numericality: { greater_than_or_equal_to: 0 }, if: -> { wages.present? }
    validates :locality_nm, presence: { message: ->(_object, _data) { I18n.t('state_file.questions.w2.edit.locality_nm_missing_error') } }, if: -> { local_wages_and_tips_amount.present? && local_wages_and_tips_amount.positive? && StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code) }
    validates :employer_state_id_num, presence: true, if: -> { state_wages_amount.present? && state_wages_amount.positive? }
    validates :employer_ein, presence: true, format: { with: /\A[0-9]{9}\z/, message: ->(*_args) { I18n.t('validators.ein') } }
    validates :locality_nm, format: { with: /\A[a-zA-Z]{1}([A-Za-z\-\s']{0,19})\z/, message: :only_letters }, if: -> { locality_nm.present? && StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code) }
    validate :validate_box14_limits, if: :check_box14_limits
    validate :validate_tax_amts
    validate :state_specific_validation
  end

  validate :validate_nil_tax_amounts, on: :state_file_edit

  before_validation :locality_nm_to_upper_case

  def state_specific_validation
    state_file_intake.validate_state_specific_w2_requirements(self) if state_file_intake.present?
  end

  def validate_nil_tax_amounts
    [:state_wages_amount, :state_income_tax_amount].each do |amount|
      if self.send(amount).nil?
        errors.add(amount, I18n.t('state_file.questions.w2.edit.no_money_amount'))
      end
    end

    if StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code)
      [:local_wages_and_tips_amount, :local_income_tax_amount].each do |amount|
        if self.send(amount).nil?
          errors.add(amount, I18n.t('state_file.questions.w2.edit.no_money_amount'))
        end
      end
    end

    supported_box14_codes.each do |code|
      attribute_name = "box14_#{code.downcase}"
      if self.send(attribute_name.to_sym).nil?
        errors.add(attribute_name, I18n.t('state_file.questions.w2.edit.no_money_amount'))
      end
    end
  end

  def validate_tax_amts
    if (state_income_tax_amount || 0).positive? && (state_wages_amount || 0) <= 0
      errors.add(:state_wages_amount, I18n.t("state_file.questions.w2.edit.state_wages_amt_error"))
    end
    if state_income_tax_amount.present? && state_wages_amount.present? && state_income_tax_amount > state_wages_amount
      errors.add(:state_income_tax_amount, I18n.t("state_file.questions.w2.edit.state_income_tax_amt_error"))
    end
    if StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code)
      if (local_income_tax_amount || 0).positive? && (local_wages_and_tips_amount || 0) <= 0
        errors.add(:local_wages_and_tips_amount, I18n.t("state_file.questions.w2.edit.local_wages_and_tips_amt_error"))
      end
      if local_income_tax_amount.present? && local_wages_and_tips_amount.present? && local_income_tax_amount > local_wages_and_tips_amount
        errors.add(:local_income_tax_amount, I18n.t("state_file.questions.w2.edit.local_income_tax_amt_error"))
      end
    end
    w2 = state_file_intake.direct_file_data.w2s[w2_index]
    if w2.present?
      if StateFile::StateInformationService.w2_include_local_income_boxes(state_file_intake.state_code)
        if state_income_tax_amount.present? && local_income_tax_amount.present? && (state_income_tax_amount + local_income_tax_amount > w2.WagesAmt)
          errors.add(:local_income_tax_amount, I18n.t("state_file.questions.w2.edit.wages_amt_error", wages_amount: w2.WagesAmt))
          errors.add(:state_income_tax_amount, I18n.t("state_file.questions.w2.edit.wages_amt_error", wages_amount: w2.WagesAmt))
        end
      elsif state_income_tax_amount.present? && state_income_tax_amount > w2.WagesAmt
        errors.add(:state_income_tax_amount, I18n.t("state_file.questions.w2.edit.wages_amt_error", wages_amount: w2.WagesAmt))
      end
      if state_wages_amount != w2.StateWagesAmt && state_wages_amount == StateFileBaseIntake::DB_NUMERIC_MAX
        errors.add(:state_wages_amount, I18n.t("state_file.questions.w2.edit.review_box_14"))
      end
    end
  end

  def locality_nm_to_upper_case
    if locality_nm.present?
      self.locality_nm = locality_nm.upcase
    end
  end

  def state_tax_group_xml_node
    df_w2 = state_file_intake.direct_file_data.w2s[w2_index]
    state_code = if df_w2&.StateAbbreviationCd.present?
                   df_w2.StateAbbreviationCd
                 else
                   state_file_intake.state_code
                 end

    xml_template = Nokogiri::XML(STATE_TAX_GRP_TEMPLATE)
    xml_template.at(:StateAbbreviationCd).content = state_code&.upcase
    xml_template.at(:EmployerStateIdNum).content = sanitize_for_xml(employer_state_id_num.delete("\u00AD")) if employer_state_id_num.present?
    xml_template.at(:StateWagesAmt).content = state_wages_amount&.round
    xml_template.at(:StateIncomeTaxAmt).content = state_income_tax_amount&.round
    xml_template.at(:LocalWagesAndTipsAmt).content = local_wages_and_tips_amount&.round
    xml_template.at(:LocalIncomeTaxAmt).content = local_income_tax_amount&.round
    xml_template.at(:LocalityNm).content = sanitize_for_xml(locality_nm)
    delete_blank_nodes(xml_template)
    result = xml_template.at(:W2StateTaxGrp)
    result.nil? ? "" : result.to_xml
  end

  def get_box14_ui_overwrite
    box14_ui_wf_swf || box14_ui_hc_wd
  end

  def self.find_limit(name, state_code)
    code = StateFile::StateInformationService
             .w2_supported_box14_codes(state_code)
             .find { |code| code[:name] == name }
    code ? code[:limit] : nil
  end

  private

  def supported_box14_codes
    box14_codes = StateFile::StateInformationService.w2_supported_box14_codes(state_file_intake.state_code)
    box14_codes.map { |code| code[:name] }
  end

  def validate_box14_limits
    validate_limit(:box14_ui_wf_swf, self.class.find_limit("UI_WF_SWF", state_file_intake.state_code))
    validate_limit(:box14_fli, self.class.find_limit("FLI", state_file_intake.state_code))
  end

  def validate_limit(field, limit)
    value = send(field)
    if value.present? && limit.present? && value > limit
      errors.add(field, I18n.t("validators.dollar_limit", limit: '%.2f' % limit))
    end
  end
end
