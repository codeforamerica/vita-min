module Ctc
  class LegalConsentForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_first_name,
                              :primary_middle_initial,
                              :primary_last_name,
                              :primary_birth_date,
                              :primary_ssn,
                              :sms_phone_number
    set_attributes_for :confirmation, :primary_ssn_confirmation

    before_validation :normalize_phone_numbers

    validates :sms_phone_number, e164_phone: true
    validates :primary_first_name, presence: true
    validates :primary_middle_initial, presence: true
    validates :primary_last_name, presence: true
    validates :primary_birth_date, presence: true
    validates :primary_birth_date
    validates :primary_ssn, confirmation: true
    validates :primary_ssn_confirmation, presence: true
    validates :primary_ssn, social_security_number: true

    def save
      @intake.update(attributes_for(:intake)
                       .except(:primary_birth_date_year, :primary_birth_date_month, :primary_birth_date_day)
                                           .merge(
                                             primary_birth_date: parse_birth_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day)
                                           )
      )
    end

    private

    def primary_birth_date
      valid_text_birth_date(:primary_birth_date, primary_birth_date_year, primary_birth_date_month, primary_birth_date_day)
    end

    def normalize_phone_numbers
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number) if sms_phone_number.present?
    end
  end
end