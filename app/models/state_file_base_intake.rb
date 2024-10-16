class StateFileBaseIntake < ApplicationRecord
  devise :lockable, :timeoutable, :trackable

  self.abstract_class = true
  has_one_attached :submission_pdf
  has_many :dependents, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileDependent', inverse_of: :intake, dependent: :destroy
  has_many :efile_submissions, -> { order(created_at: :asc) }, as: :data_source, class_name: 'EfileSubmission', inverse_of: :data_source, dependent: :destroy
  has_many :state_file1099_gs, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFile1099G', inverse_of: :intake, dependent: :destroy
  has_many :state_file1099_rs, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFile1099R', inverse_of: :intake, dependent: :destroy
  has_many :efile_device_infos, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileEfileDeviceInfo', inverse_of: :intake, dependent: :destroy
  has_many :state_file_w2s, as: :state_file_intake, class_name: "StateFileW2", inverse_of: :state_file_intake, dependent: :destroy
  has_many :df_data_import_errors, -> { order(created_at: :asc) }, as: :state_file_intake, class_name: "DfDataImportError", inverse_of: :state_file_intake, dependent: :destroy
  has_one :state_file_analytics, as: :record, dependent: :destroy
  belongs_to :primary_state_id, class_name: "StateId", optional: true
  belongs_to :spouse_state_id, class_name: "StateId", optional: true
  accepts_nested_attributes_for :primary_state_id, :spouse_state_id

  scope :accessible_intakes, -> { all }
  devise :timeoutable, :timeout_in => 15.minutes, :unlock_strategy => :time

  validates :email_address, 'valid_email_2/email': true
  validates :phone_number, allow_blank: true, e164_phone: true
  accepts_nested_attributes_for :dependents, update_only: true
  delegate :tax_return_year, to: :direct_file_data
  alias_attribute :sms_phone_number, :phone_number

  enum contact_preference: { unfilled: 0, email: 1, text: 2 }, _prefix: :contact_preference
  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income
  enum primary_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_esigned
  enum spouse_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_esigned
  enum account_type: { unfilled: 0, checking: 1, savings: 2}, _prefix: :account_type
  enum payment_or_deposit_type: { unfilled: 0, direct_deposit: 1, mail: 2 }, _prefix: :payment_or_deposit_type
  enum consented_to_terms_and_conditions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_terms_and_conditions
  scope :with_df_data_and_no_federal_submission, lambda {
    where.not(raw_direct_file_data: nil)
         .where(federal_submission_id: nil)
  }
  before_save :save_nil_enums_with_unfilled
  before_save :sanitize_bank_details

  def self.state_code
    state_code, _ = StateFile::StateInformationService::STATES_INFO.find do |_, state_info|
      state_info[:intake_class] == self
    end
    state_code.to_s
  end
  delegate :state_code, to: :class

  def state_name
    StateFile::StateInformationService.state_name(state_code)
  end

  def direct_file_data
    @direct_file_data ||= DirectFileData.new(raw_direct_file_data)
  end

  def direct_file_json_data
    @direct_file_json_data ||= DirectFileJsonData.new(raw_direct_file_intake_data)
  end

  def synchronize_filers_to_database
    attributes_to_update = {}

    if direct_file_json_data.primary_filer.present?
      attributes_to_update.merge!(
        primary_first_name: direct_file_json_data.primary_first_name,
        primary_middle_initial: direct_file_json_data.primary_middle_initial,
        primary_last_name: direct_file_json_data.primary_last_name,
        primary_birth_date: direct_file_json_data.primary_dob
      )
    end

    if filing_status_mfj? && direct_file_json_data.spouse_filer.present?
      attributes_to_update.merge!(
        spouse_first_name: direct_file_json_data.spouse_first_name,
        spouse_middle_initial: direct_file_json_data.spouse_middle_initial,
        spouse_last_name: direct_file_json_data.spouse_last_name,
        spouse_birth_date: direct_file_json_data.spouse_dob
      )
    end

    update(attributes_to_update) if attributes_to_update.present?
  end

  def synchronize_df_dependents_to_database
    direct_file_data.dependents.each do |direct_file_dependent|
      dependent = dependents.find { |d| d.ssn == direct_file_dependent.ssn } || dependents.build
      dependent.assign_attributes(direct_file_dependent.attributes)

      dependent_json = direct_file_json_data.find_matching_json_dependent(dependent)
      if dependent_json.present?
        json_attributes = {
          middle_initial: dependent_json.middle_initial,
          relationship: dependent_json.relationship&.humanize,
          dob: dependent_json.dob
        }
        dependent.assign_attributes(json_attributes)
      end
      dependent.assign_attributes(intake_id: self.id, intake_type: self.class.to_s)
      dependent.save!
    end
  end

  def synchronize_df_1099_rs_to_database
    direct_file_data.form1099rs.each_with_index do |direct_file_1099_r, i|
      state_file1099_r = state_file1099_rs[i] || state_file1099_rs.build
      state_file1099_r.assign_attributes(direct_file_1099_r.to_h)
      state_file1099_r.assign_attributes(intake: self)
      state_file1099_r.save!
    end
  end

  def calculator
    unless @calculator.present?
      @calculator = tax_calculator
      @calculator.calculate
    end
    @calculator
  end

  def tax_calculator(include_source: false)
    StateFile::StateInformationService.calculator_class(state_code).new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: self,
      include_source: include_source
    )
  end

  def calculated_refund_or_owed_amount
    calculator.refund_or_owed_amount
  end

  def refund_or_owe_taxes_type
    amt = calculated_refund_or_owed_amount
    if amt.zero?
      :none
    elsif amt.positive?
      :refund
    elsif amt.negative?
      :owe
    end
  end

  def filing_status
    {
      1 => :single,
      2 => :married_filing_jointly,
      3 => :married_filing_separately,
      4 => :head_of_household,
      5 => :qualifying_widow,
    }[direct_file_data&.filing_status]
  end

  def filing_status_single?
    filing_status == :single
  end

  def filing_status_mfj?
    filing_status == :married_filing_jointly
  end

  def filing_status_mfs?
    filing_status == :married_filing_separately
  end

  def filing_status_hoh?
    filing_status == :head_of_household
  end

  def filing_status_qw?
    filing_status == :qualifying_widow
  end

  def filer_count
    filing_status_mfj? ? 2 : 1
  end

  def primary
    Person.new(self, :primary)
  end

  def spouse
    Person.new(self, :spouse)
  end

  def ask_spouse_dob?
    filing_status_mfj?
  end

  def ask_spouse_name?
    filing_status_mfj?
  end

  def ask_months_in_home?
    false
  end

  def ask_spouse_esign?
    filing_status_mfj? && !spouse_deceased?
  end

  def spouse_deceased?
    direct_file_data.spouse_deceased?
  end

  def validate_state_specific_w2_requirements(w2)
  end

  def invalid_df_w2?(df_w2)
    return true if df_w2.StateWagesAmt == 0
    if df_w2.LocalityNm.blank?
      return true if df_w2.LocalWagesAndTipsAmt != 0 || df_w2.LocalIncomeTaxAmt != 0
    end
    return true if df_w2.LocalIncomeTaxAmt != 0 && df_w2.LocalWagesAndTipsAmt == 0
    return true if df_w2.StateIncomeTaxAmt != 0 && df_w2.StateWagesAmt == 0
    return true if df_w2.StateWagesAmt != 0 && df_w2.EmployerStateIdNum.blank?
    return true if df_w2.EmployerStateIdNum.present? && df_w2.StateAbbreviationCd.blank?
    return true if df_w2.StateIncomeTaxAmt > df_w2.StateWagesAmt
    return true if df_w2.LocalIncomeTaxAmt > df_w2.LocalWagesAndTipsAmt
    return true if df_w2.StateIncomeTaxAmt + df_w2.LocalIncomeTaxAmt > df_w2.WagesAmt
    false
  end

  def validate_state_specific_1099_g_requirements(state_file1099_g)
    unless /\A\d{9}\z/.match(state_file1099_g.payer_tin)
      state_file1099_g.errors.add(:payer_tin, I18n.t("errors.attributes.payer_tin.invalid"))
    end
  end

  class Person
    attr_reader :first_name
    attr_reader :middle_initial
    attr_reader :last_name
    attr_reader :suffix
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @middle_initial = intake.primary_middle_initial
        @suffix = intake.primary_suffix
        @birth_date = intake.primary_birth_date
        @ssn = intake.direct_file_data.primary_ssn
      else
        @first_name = intake.spouse_first_name
        @last_name = intake.spouse_last_name
        @middle_initial = intake.spouse_middle_initial
        @suffix = intake.spouse_suffix
        @birth_date = intake.spouse_birth_date if intake.ask_spouse_dob?
        @ssn = intake.direct_file_data.spouse_ssn
      end
    end

    def full_name
      [@first_name, @middle_initial, @last_name, @suffix].map(&:presence).compact.join(' ')
    end

    def first_name_and_middle_initial
      [@first_name, @middle_initial].map(&:presence).compact.join(' ')
    end

    def last_name_and_suffix
      [@last_name, @suffix].map(&:presence).compact.join(' ')
    end

    def has_itin?
      starts_with_9 = @ssn.start_with?('9')
      digits_4_and_5 = @ssn[3, 2].to_i

      in_valid_range = (50..65).include?(digits_4_and_5) || (70..88).include?(digits_4_and_5) || (90..92).include?(digits_4_and_5) || (94..99).include?(digits_4_and_5)
      starts_with_9 && in_valid_range
    end
  end

  def disqualifying_eligibility_answer
    disqualifying_eligibility_rules.each do |col, value|
      return col if self.public_send(col) == value
    end

    nil
  end

  def has_disqualifying_eligibility_answer?
    disqualifying_eligibility_answer.present?
  end

  def initial_efile_device_info
    with_device_id = efile_device_infos.where(event_type: "initial_creation").where.not(device_id: nil).first
    with_device_id.present? ? with_device_id : efile_device_infos.where(event_type: "initial_creation").first
  end

  def submission_efile_device_info
    with_device_id = efile_device_infos.where(event_type: "submission").where.not(device_id: nil).first
    with_device_id.present? ? with_device_id : efile_device_infos.where(event_type: "submission").first
  end

  def save_nil_enums_with_unfilled
    keys_with_unfilled = self.defined_enums.map{ |e| e.first if e.last.include?("unfilled") }
    keys_with_unfilled.each do |key|
      if self.send(key) == nil
        self.send("#{key}=", "unfilled")
      end
    end
  end

  def latest_submission
    self.efile_submissions&.last
  end

  def increment_failed_attempts
    super
    if attempts_exceeded?
      lock_access! unless access_locked?
    end
  end

  def controller_for_current_step
    begin
      if efile_submissions.present?
        StateFile::Questions::ReturnStatusController
      else
        step_name = current_step.split('/').last
        controller_name = "StateFile::Questions::#{step_name.underscore.camelize}Controller"
        controller_name.constantize
      end
    rescue
      if hashed_ssn.present?
        StateFile::Questions::DataReviewController
      else
        StateFile::Questions::TermsAndConditionsController
      end
    end
  end

  def self.opted_out_state_file_intakes(email)
    StateFile::StateInformationService.state_intake_classes.map do |klass|
      klass.where(email_address: email).where(unsubscribed_from_email: true)
    end.inject([], :+)
  end

  def sanitize_bank_details
    if (payment_or_deposit_type || "").to_sym != :direct_deposit
      self.account_type = "unfilled"
      self.bank_name = nil
      self.routing_number = nil
      self.account_number = nil
      self.withdraw_amount = nil
      self.date_electronic_withdrawal = nil
    end
  end
end
