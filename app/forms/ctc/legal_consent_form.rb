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
                       :primary_active_armed_forces,
                       :timezone
    set_attributes_for :birthday, :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year
    set_attributes_for :confirmation, :primary_ssn_confirmation
    set_attributes_for :efile_security_information,
                       :device_id,
                       :user_agent,
                       :browser_language,
                       :platform,
                       :timezone_offset,
                       :client_system_time,
                       :ip_address
    set_attributes_for :misc, :ssn_no_employment

    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true
    validates :primary_first_name, presence: true, legal_name: true
    validates :primary_last_name, presence: true, legal_name: true
    validates :primary_middle_initial, length: { maximum: 1 }, legal_name: true
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

    def initialize(intake, params)
      super
      if primary_tin_type == "ssn_no_employment"
        self.primary_tin_type = "ssn"
        self.ssn_no_employment = "yes"
      end
    end

    before_validation do
      if ssn_no_employment == "yes" && primary_tin_type == "ssn"
        self.primary_tin_type = "ssn_no_employment"
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
      efile_attrs = attributes_for(:efile_security_information).merge(timezone_offset: format_timezone_offset(timezone_offset))
      client = Client.create!(
        intake_attributes: intake_attributes,
        tax_returns_attributes: [tax_return_attributes],
        efile_security_information_attributes: efile_attrs
      )
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

    def format_timezone_offset(tz_offset)
      return unless tz_offset.present?

      return (tz_offset.include?("-") || tz_offset.include?("+")) ? tz_offset : "+" + tz_offset
    end
  end
end
