module Ctc
  class BasePrimaryFilerForm < QuestionsForm
    include BirthDateHelper

    validates :primary_first_name, presence: true, legal_name: true
    validates :primary_last_name, presence: true, legal_name: true
    validates :primary_middle_initial, length: { maximum: 1 }, legal_name: true
    validate  :primary_birth_date_is_valid_date
    validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
    validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }

    before_validation { primary_ssn&.remove!("-") }
    with_options if: -> { (primary_ssn.present? && primary_ssn != intake.primary_ssn) || primary_ssn_confirmation.present? } do
      validates :primary_ssn, confirmation: true
      validates :primary_ssn_confirmation, presence: true
    end

    def save
      @intake.update!(
        attributes_for(:intake).merge(
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
