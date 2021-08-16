module Ctc
  class LegalConsentForm < QuestionsForm
    include BirthDateHelper
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_middle_initial,
                       :primary_last_name,
                       :primary_suffix,
                       :primary_ssn,
                       :phone_number,
                       :primary_tin_type,
                       :primary_active_armed_forces
    set_attributes_for :birthday, :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year
    set_attributes_for :confirmation, :primary_ssn_confirmation
    set_attributes_for :misc, :ssn_no_employment

    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true
    validates :primary_first_name, presence: true, legal_name: true
    validates :primary_last_name, presence: true, legal_name: true
    validates :primary_middle_initial, length: { maximum: 1 }, legal_name: true
    validate  :primary_birth_date_is_valid_date
    validates :primary_ssn, social_security_number: true, if: -> { primary_tin_type == "ssn" }
    validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }

    with_options if: -> { (primary_ssn.present? && primary_ssn != intake.primary_ssn) || primary_ssn_confirmation.present? } do
      validates :primary_ssn, confirmation: true
      validates :primary_ssn_confirmation, presence: true
    end

    before_validation do
      if ssn_no_employment == "yes" && primary_tin_type == "ssn"
        self.primary_tin_type = "ssn_no_employment"
      end
    end

    def initialize(intake, params)
      super
      if primary_tin_type == "ssn_no_employment"
        self.primary_tin_type = "ssn"
        self.ssn_no_employment = "yes"
      end
    end

    def save
      primary_last_four_ssn = primary_ssn.last(4) # merge last_four_ssn so that client can use data for logging in.
      @intake.update!(
        attributes_for(:intake).merge(
          primary_last_four_ssn: primary_last_four_ssn,
          primary_birth_date: primary_birth_date
        )
      )
    end

    def self.existing_attributes(intake, _attribute_keys)
      if intake.primary_birth_date.present?
        super.merge(
          primary_birth_date_day: intake.primary_birth_date.day,
          primary_birth_date_month: intake.primary_birth_date.month,
          primary_birth_date_year: intake.primary_birth_date.year,
        )
      else
        super
      end
    end

    private

    def tax_return_attributes
      {
          year: 2020,
          is_ctc: true
      }
    end

    def primary_birth_date
      parse_birth_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day)
    end

    def primary_birth_date_is_valid_date
      valid_text_birth_date(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day, :primary_birth_date)
    end

    def normalize_phone_numbers
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end
  end
end
