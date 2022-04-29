module Ctc
  class LegalConsentForm < BasePrimaryFilerForm
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
    set_attributes_for :recaptcha, :recaptcha_score, :recaptcha_action

    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true

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
      super
      if attributes_for(:recaptcha)[:recaptcha_score].present?
        @intake.client.recaptcha_scores.create(
          score: attributes_for(:recaptcha)[:recaptcha_score],
          action: attributes_for(:recaptcha)[:recaptcha_action]
        )
      end
    end

    private

    def normalize_phone_numbers
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end
  end
end
