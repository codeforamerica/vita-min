class StateFileBaseIntake < ApplicationRecord
  devise :lockable, :timeoutable, :trackable

  self.abstract_class = true
  has_one_attached :submission_pdf
  has_many :dependents, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileDependent', inverse_of: :intake, dependent: :destroy
  has_many :efile_submissions, -> { order(created_at: :asc) }, as: :data_source, class_name: 'EfileSubmission', inverse_of: :data_source, dependent: :destroy
  has_many :state_file1099_gs, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFile1099G', inverse_of: :intake, dependent: :destroy
  has_many :efile_device_infos, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileEfileDeviceInfo', inverse_of: :intake, dependent: :destroy
  belongs_to :primary_state_id, class_name: "StateId", optional: true
  belongs_to :spouse_state_id, class_name: "StateId", optional: true
  accepts_nested_attributes_for :primary_state_id, :spouse_state_id

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

  def direct_file_data
    @direct_file_data ||= DirectFileData.new(raw_direct_file_data)
  end

  def synchronize_df_dependents_to_database
    direct_file_data.dependents.each do |direct_file_dependent|
      dependent = dependents.find { |d| d.ssn == direct_file_dependent.ssn } || dependents.build
      dependent.assign_attributes(direct_file_dependent.attributes)
      dependent.save
    end
  end

  def calculated_refund_or_owed_amount
    calculator = tax_calculator
    calculator.calculate
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

  def filing_status_mfj?
    filing_status == :married_filing_jointly
  end

  def filing_status_mfs?
    filing_status == :married_filing_separately
  end

  def primary
    Person.new(self, :primary)
  end

  def spouse
    Person.new(self, :spouse)
  end

  class Person
    attr_reader :first_name
    attr_reader :middle_initial
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @middle_initial = intake.primary_middle_initial
        @birth_date = intake.primary_birth_date if intake.ask_primary_dob?
        @ssn = intake.direct_file_data.primary_ssn
      else
        @first_name = intake.spouse_first_name
        @last_name = intake.spouse_last_name
        @middle_initial = intake.spouse_middle_initial
        @birth_date = intake.spouse_birth_date if intake.ask_spouse_dob?
        @ssn = intake.direct_file_data.spouse_ssn
      end
    end

    def full_name
      [@first_name, @middle_initial, @last_name].map(&:presence).compact.join(' ')
    end

    def first_name_and_middle_initial
      [@first_name, @middle_initial].map(&:presence).compact.join(' ')
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

  # Any statuses besides an accepted/rejected can lead back to these terminal states via resubmission.
  def return_status
    case self.efile_submissions.last.current_state
    when 'accepted'
      'accepted'
    when 'rejected'
      'rejected'
    else
      'pending'
    end
  end
end
