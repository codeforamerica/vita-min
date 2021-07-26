module Ctc
  class ConsentForm < QuestionsForm
    include BirthDateHelper
    set_attributes_for :intake,
                       :primary_first_name,
                              :primary_middle_initial,
                              :primary_last_name,
                              :primary_ssn,
                              :phone_number,
                              :primary_tin_type,
                              :timezone
    set_attributes_for :birthday, :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year
    set_attributes_for :confirmation, :primary_ssn_confirmation

    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true
    validates :primary_first_name, presence: true
    validates :primary_last_name, presence: true
    validate  :primary_birth_date_is_valid_date
    validates :primary_ssn, confirmation: true
    validates :primary_ssn_confirmation, presence: true
    validates :primary_ssn, social_security_number: true, if: -> { primary_tin_type == "ssn" }
    validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }

    before_validation do
      [primary_ssn, primary_ssn_confirmation].each do |field|
        field.remove!(/\D/) if field
      end
    end

    def save
      primary_last_four_ssn = primary_ssn.last(4) # merge last_four_ssn so that client can use data for logging in.
      intake_attributes = attributes_for(:intake).merge(
          primary_last_four_ssn: primary_last_four_ssn,
          primary_birth_date: primary_birth_date,
          visitor_id: @intake.visitor_id,
          source: @intake.source,
          type: @intake.type
      )
      client = Client.create!(intake_attributes: intake_attributes, tax_returns_attributes: [tax_return_attributes])
      @intake = client.intake
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