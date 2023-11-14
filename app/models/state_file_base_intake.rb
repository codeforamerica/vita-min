class StateFileBaseIntake < ApplicationRecord
  self.abstract_class = true

  enum claimed_as_dep: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claimed_as_dep
  enum contact_preference: { unfilled: 0, email: 1, text: 2 }, _prefix: :contact_preference
  enum eligibility_lived_in_state: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_lived_in_state
  enum eligibility_out_of_state_income: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eligibility_out_of_state_income

  has_one_attached :submission_pdf

  has_many :dependents, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileDependent', inverse_of: :intake, dependent: :destroy
  has_many :efile_submissions, -> { order(created_at: :asc) }, as: :data_source, class_name: 'EfileSubmission', inverse_of: :data_source, dependent: :destroy
  has_many :state_file1099_gs, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFile1099G', inverse_of: :intake, dependent: :destroy

  validates :email_address, 'valid_email_2/email': true
  validates :phone_number, allow_blank: true, e164_phone: true

  accepts_nested_attributes_for :dependents, update_only: true

  delegate :tax_return_year, to: :direct_file_data

  alias_attribute :sms_phone_number, :phone_number

  def direct_file_data
    @direct_file_data ||= DirectFileData.new(raw_direct_file_data)
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
    attr_reader :state_id

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @middle_initial = intake.primary_middle_initial
        @birth_date = intake.primary_birth_date if intake.ask_primary_dob?
        @ssn = intake.direct_file_data.primary_ssn
        @state_id = intake.primary_state_id
      else
        @first_name = intake.spouse_first_name
        @last_name = intake.spouse_last_name
        @middle_initial = intake.spouse_middle_initial
        @birth_date = intake.spouse_birth_date if intake.ask_spouse_dob?
        @ssn = intake.direct_file_data.spouse_ssn
        @state_id = intake.spouse_state_id
      end
    end

    def full_name
      [@first_name, @middle_initial, @last_name].map(&:presence).compact.join(' ')
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
end
