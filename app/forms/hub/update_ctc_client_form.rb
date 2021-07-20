module Hub
  class UpdateCtcClientForm < ClientForm
    include BirthDateHelper
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_last_name,
                       :primary_birth_date_month,
                       :primary_birth_date_day,
                       :primary_birth_date_year,
                       :spouse_birth_date_month,
                       :spouse_birth_date_day,
                       :spouse_birth_date_year,
                       :preferred_name,
                       :preferred_interview_language,
                       :email_address,
                       :phone_number,
                       :sms_phone_number,
                       :street_address,
                       :city,
                       :state,
                       :state_of_residence,
                       :zip_code,
                       :primary_ssn,
                       :primary_ssn_confirmation,
                       :spouse_ssn,
                       :spouse_ssn_confirmation,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :interview_timing_preference,
                       :with_general_navigator,
                       :with_incarcerated_navigator,
                       :with_limited_english_navigator,
                       :with_unhoused_navigator,
                       :with_drivers_license_photo_id,
                       :with_passport_photo_id,
                       :with_other_state_photo_id,
                       :with_vita_approved_photo_id,
                       :with_social_security_taxpayer_id,
                       :with_itin_taxpayer_id,
                       :with_vita_approved_taxpayer_id,
                       :recovery_rebate_credit_amount_1,
                       :recovery_rebate_credit_amount_2,
                       :recovery_rebate_credit_amount_confidence,
                       :refund_payment_method,
                       :primary_ip_pin,
                       :spouse_ip_pin
    set_attributes_for :tax_return,
                       :filing_status,
                       :filing_status_note
    set_attributes_for :confirmation,
                       :account_number_confirmation,
                       :routing_number_confirmation,
                       :primary_ssn_confirmation,
                       :spouse_ssn_confirmation
    set_attributes_for :bank_account,
                       :routing_number,
                       :account_number,
                       :bank_name,
                       :account_type
    attr_accessor :client

    validates :refund_payment_method, presence: true
    with_options if: -> { refund_payment_method == "direct_deposit" } do
      validates_confirmation_of :routing_number
      validates_confirmation_of :account_number
      validates_presence_of :bank_name
      validates_presence_of :account_type
      validates_presence_of :account_number
      validates_presence_of :routing_number
    end

    validates_presence_of :account_number_confirmation, if: :account_number
    validates_presence_of :routing_number_confirmation, if: :routing_number

    validates_confirmation_of :primary_ssn
    validates_presence_of :primary_ssn_confirmation, if: :primary_ssn
    validates_presence_of :spouse_ssn_confirmation, if: :spouse_ssn
    validates :primary_ssn, social_security_number: true

    with_options if: -> { filing_status == "married_filing_jointly" } do
      validates_confirmation_of :spouse_ssn
      validates :spouse_ssn, social_security_number: true
    end

    validates :primary_ip_pin, ip_pin: true
    validates :spouse_ip_pin, ip_pin: true

    validate :at_least_one_photo_id_type_selected
    validate :at_least_one_taxpayer_id_type_selected
    validate :valid_primary_birth_date
    validate :valid_spouse_birth_date, if: -> { filing_status == "married_filing_jointly" }

    def initialize(client, params = {})
      @client = client
      super(params)
      # parent Form class creates setters for each attribute -- won't work til super is called!
      self.preferred_name = preferred_name.presence || "#{primary_first_name} #{primary_last_name}"
    end

    def self.existing_attributes(intake)
      non_model_attrs = {
        spouse_ssn: intake.spouse_ssn,
        spouse_ssn_confirmation: intake.spouse_ssn,
        primary_ssn: intake.primary_ssn,
        primary_ssn_confirmation: intake.primary_ssn,
      }
      tax_return_attrs = {
        filing_status: intake.client.tax_returns.last.filing_status,
        filing_status_note: intake.client.tax_returns.last.filing_status_note,
      }
      super.merge(non_model_attrs).merge(date_of_birth_attributes(intake)).merge(tax_return_attrs)
    end

    def default_attributes
      {
        type: "Intake::CtcIntake",
        primary_last_four_ssn: primary_ssn&.last(4),
        spouse_last_four_ssn: spouse_ssn&.last(4),
      }
    end

    def self.date_of_birth_attributes(intake)
      {
        primary_birth_date_day: intake.primary_birth_date&.day,
        primary_birth_date_month: intake.primary_birth_date&.month,
        primary_birth_date_year: intake.primary_birth_date&.year,
        spouse_birth_date_day: intake.spouse_birth_date&.day,
        spouse_birth_date_month: intake.spouse_birth_date&.month,
        spouse_birth_date_year: intake.spouse_birth_date&.year
      }
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      return false unless valid?
      intake_attr = attributes_for(:intake)
                       .except(:primary_birth_date_year, :primary_birth_date_month, :primary_birth_date_day,
                        :spouse_birth_date_year, :spouse_birth_date_month, :spouse_birth_date_day, :primary_ssn_confirmation, :spouse_ssn_confirmation)
                       .merge(
                         default_attributes,
                         dependents_attributes: formatted_dependents_attributes,
                         primary_birth_date: parse_birth_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day),
                         spouse_birth_date: parse_birth_date_params(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day))
      @client.intake.update(intake_attr)
      # only updates the last tax return because we assume that a CTC client only has a single tax return
      @client.tax_returns.last.update(attributes_for(:tax_return))
    end

    private

    def at_least_one_photo_id_type_selected
      photo_id_selected = Intake::CtcIntake::PHOTO_ID_TYPES.any? do |_, type|
        self.send(type[:field_name]) == "1"
      end

      errors.add(:photo_id_type, I18n.t("hub.clients.fields.photo_id.error")) unless photo_id_selected
    end

    def at_least_one_taxpayer_id_type_selected
      taxpayer_id_selected = Intake::CtcIntake::TAXPAYER_ID_TYPES.any? do |_, type|
        self.send(type[:field_name]) == "1"
      end

      errors.add(:taxpayer_id_type, I18n.t("hub.clients.fields.taxpayer_id.error")) unless taxpayer_id_selected
    end
  end
end
