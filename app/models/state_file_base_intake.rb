class StateFileBaseIntake < ApplicationRecord
  self.ignored_columns = [:df_data_import_failed_at, :bank_name]

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
  enum primary_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_esigned
  enum spouse_esigned: { unfilled: 0, yes: 1, no: 2 }, _prefix: :spouse_esigned
  enum account_type: { unfilled: 0, checking: 1, savings: 2 }, _prefix: :account_type
  enum payment_or_deposit_type: { unfilled: 0, direct_deposit: 1, mail: 2 }, _prefix: :payment_or_deposit_type # direct deposit includes both direct_deposit and direct_debit
  enum consented_to_terms_and_conditions: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_terms_and_conditions
  enum consented_to_sms_terms: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_sms_terms
  scope :with_df_data_and_no_federal_submission, lambda {
    where.not(raw_direct_file_data: nil)
         .where(federal_submission_id: nil)
  }
  before_save :save_nil_enums_with_unfilled
  before_save :sanitize_bank_details

  def self.state_code
    state_code, = StateFile::StateInformationService::STATES_INFO.find do |_, state_info|
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
        primary_first_name: direct_file_json_data.primary_filer.first_name,
        primary_middle_initial: direct_file_json_data.primary_filer.middle_initial,
        primary_last_name: direct_file_json_data.primary_filer.last_name,
        primary_suffix: direct_file_json_data.primary_filer.suffix,
        primary_birth_date: direct_file_json_data.primary_filer.dob
      )
    end

    if (filing_status_mfj? || filing_status_mfs?) && direct_file_json_data.spouse_filer.present?
      attributes_to_update.merge!(
        spouse_first_name: direct_file_json_data.spouse_filer.first_name,
        spouse_middle_initial: direct_file_json_data.spouse_filer.middle_initial,
        spouse_last_name: direct_file_json_data.spouse_filer.last_name,
        spouse_suffix: direct_file_json_data.spouse_filer.suffix,
        spouse_birth_date: direct_file_json_data.spouse_filer.dob
      )
    end

    update(attributes_to_update) if attributes_to_update.present?
  end

  class SynchronizeError < StandardError; end

  def synchronize_df_dependents_to_database
    direct_file_data.dependents.each do |direct_file_dependent|
      dependent = dependents.find { |d| d.ssn == direct_file_dependent.ssn } || dependents.build
      dependent.assign_attributes(direct_file_dependent.attributes)

      dependent_json = direct_file_json_data.find_matching_json_dependent(dependent)

      if direct_file_json_data.data.present? && dependent_json.nil?
        raise SynchronizeError, "Could not find matching dependent #{dependent.id} with #{state_name} intake id: #{id}"
      end

      if dependent_json.present?
        json_attributes = {
          first_name: dependent_json.first_name,
          middle_initial: dependent_json.middle_initial,
          last_name: dependent_json.last_name,
          suffix: dependent_json.suffix,
          relationship: dependent_json.relationship,
          months_in_home: dependent_json.months_in_home,
          dob: dependent_json.dob,
          qualifying_child: dependent_json.qualifying_child
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

  def synchronize_df_w2s_to_database
    direct_file_data.w2s.each_with_index do |direct_file_w2, i|
      state_file_w2 = state_file_w2s.where(w2_index: i).first || state_file_w2s.build
      box_14_values = {}
      direct_file_w2.w2_box14.each do |deduction|
        box_14_values[deduction[:other_description]] = deduction[:other_amount]
      end
      state_file_w2.assign_attributes(
        box14_ui_wf_swf: box_14_values['UI/WF/SWF'],
        box14_ui_hc_wd: box_14_values['UI/HC/WD'],
        box14_fli: box_14_values['FLI'],
        box14_stpickup: box_14_values['STPICKUP'],
        employer_ein: direct_file_w2.EmployerEIN,
        employer_name: direct_file_w2.EmployerName,
        employee_name: direct_file_w2.EmployeeNm,
        employee_ssn: direct_file_w2.EmployeeSSN,
        employer_state_id_num: direct_file_w2.EmployerStateIdNum,
        local_income_tax_amount: direct_file_w2.LocalIncomeTaxAmt,
        local_wages_and_tips_amount: direct_file_w2.LocalWagesAndTipsAmt,
        locality_nm: direct_file_w2.LocalityNm,
        state_income_tax_amount: direct_file_w2.StateIncomeTaxAmt,
        state_wages_amount: direct_file_w2.StateWagesAmt,
        state_file_intake: self,
        wages: direct_file_w2.WagesAmt,
        w2_index: i,
      )
      state_file_w2.save!
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

  def household_count
    filer_count + dependents.count
  end

  def primary
    Person.new(self, :primary)
  end

  def spouse
    Person.new(self, :spouse)
  end

  def ask_for_signature_pin?
    false
  end

  def show_tax_period_in_return_header?
    true
  end

  def extract_apartment_from_mailing_street?
    false
  end

  def city_name_length_20?
    true
  end

  def ask_spouse_esign?
    filing_status_mfj? && !spouse_deceased?
  end

  def spouse_deceased?
    direct_file_data.spouse_deceased?
  end

  def validate_state_specific_w2_requirements(w2)
    w2_xml = direct_file_data.w2s[w2.w2_index]
    if w2_xml.present? && w2.state_wages_amount.present? && w2.state_wages_amount > w2_xml.WagesAmt
      w2.errors.add(:state_wages_amount, I18n.t("state_file.questions.w2.edit.state_wages_exceed_amt_error", wages_amount: w2_xml.WagesAmt))
    end
  end

  def validate_state_specific_1099_g_requirements(state_file1099_g)
    unless /\A\d{9}\z/.match?(state_file1099_g.payer_tin)
      state_file1099_g.errors.add(:payer_tin, I18n.t("errors.attributes.payer_tin.invalid"))
    end
  end

  class Person
    attr_reader :first_name, :middle_initial, :last_name, :suffix, :birth_date, :ssn, :primary_or_spouse

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
        @birth_date = intake.spouse_birth_date
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
    keys_with_unfilled = self.defined_enums.map { |e| e.first if e.last.include?("unfilled") }.compact
    keys_with_unfilled.each do |key|
      if self.send(key).nil?
        self.send("#{key}=", "unfilled")
      end
    end
  end

  def latest_submission
    self.efile_submissions&.last
  end

  def increment_failed_attempts
    super
    if attempts_exceeded? && !access_locked?
      lock_access!
    end
  end

  def controller_for_current_step
    if efile_submissions.present?
      StateFile::Questions::ReturnStatusController
    else
      step_name = current_step.split('/').last
      controller_name = "StateFile::Questions::#{step_name.underscore.camelize}Controller"
      controller_name.constantize
    end
  rescue StandardError
    if hashed_ssn.present?
      StateFile::Questions::PostDataTransferController
    else
      StateFile::Questions::TermsAndConditionsController
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
      self.routing_number = nil
      self.account_number = nil
      self.withdraw_amount = nil
      self.date_electronic_withdrawal = nil
    end
  end

  def primary_senior?
    calculate_age(primary_birth_date, inclusive_of_jan_1: true) >= 65
  end

  def spouse_senior?
    # NOTE: spouse_birth_date will always be present on a valid return, but some test data does not initialize it
    return false unless spouse_birth_date.present?

    calculate_age(spouse_birth_date, inclusive_of_jan_1: true) >= 65
  end

  def calculate_age(dob, inclusive_of_jan_1:)
    # In tax returns, all ages are calculated based on the last day of the current tax year
    # Federal exception: for age related benefits, the day before your birthday is when you become older
    # - Those born on Jan 1st become older on Dec 31st (so are a year older than their birth year would indicate)
    # - This does not apply for benefits you age out of, such as turning 17 and not being a dependent anymore
    # - Maryland does not follow the "older on the day before your birthday" rule in any circumstance
    raise StandardError, "Missing date-of-birth" if dob.nil?

    birth_year = dob.year
    if inclusive_of_jan_1
      birthday_is_jan_1 = dob.month == 1 && dob.day == 1
      birth_year -= 1 if birthday_is_jan_1
    end
    MultiTenantService.statefile.current_tax_year - birth_year
  end
end
