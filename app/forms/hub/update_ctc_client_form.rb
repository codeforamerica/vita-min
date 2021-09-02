module Hub
  class UpdateCtcClientForm < ClientForm
    include BirthDateHelper
    include CtcClientFormAttributes
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_last_name,
                       :primary_suffix,
                       :primary_prior_year_agi_amount,
                       :primary_prior_year_signature_pin,
                       :spouse_prior_year_agi_amount,
                       :spouse_prior_year_signature_pin,
                       :use_spouse_name_for_name_control,
                       :preferred_name,
                       :preferred_interview_language,
                       :email_address,
                       :phone_number,
                       :sms_phone_number,
                       :street_address,
                       :street_address2,
                       :city,
                       :state,
                       :zip_code,
                       :primary_ssn,
                       :spouse_ssn,
                       :primary_tin_type,
                       :spouse_tin_type,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_suffix,
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
                       :eip1_amount_received,
                       :eip2_amount_received,
                       :eip1_and_2_amount_received_confidence,
                       :primary_ip_pin,
                       :spouse_ip_pin
    set_attributes_for :tax_return,
                       :filing_status,
                       :filing_status_note
    set_attributes_for :birthdates,
                       :primary_birth_date_month,
                       :primary_birth_date_day,
                       :primary_birth_date_year,
                       :spouse_birth_date_month,
                       :spouse_birth_date_day,
                       :spouse_birth_date_year
    attr_accessor :client

    validates :primary_ssn, social_security_number: true

    with_options if: -> { filing_status == "married_filing_jointly" } do
      validates :spouse_ssn, social_security_number: true
    end

    validates :primary_ip_pin, ip_pin: true
    validates :spouse_ip_pin, ip_pin: true

    validate :at_least_one_photo_id_type_selected, if: -> { @client.tax_returns.any? { |tax_return| tax_return.service_type == "drop_off" } }
    validate :at_least_one_taxpayer_id_type_selected, if: -> { @client.tax_returns.any? { |tax_return| tax_return.service_type == "drop_off" } }
    validate :valid_primary_birth_date
    validate :valid_spouse_birth_date, if: -> { filing_status == "married_filing_jointly" }

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.existing_attributes(intake, attribute_keys)
      intake_attrs = HashWithIndifferentAccess[(attribute_keys || []).map { |k| [k, intake.send(k)] }]

      tax_return_attrs = {
        filing_status: intake.client.tax_returns.last.filing_status,
        filing_status_note: intake.client.tax_returns.last.filing_status_note,
      }

      intake_attrs.merge(date_of_birth_attributes(intake)).merge(tax_return_attrs)
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
      attribute_keys = Attributes.new(scoped_attributes[:intake]).to_sym
      new(client, existing_attributes(intake, attribute_keys))
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
      reduce_dirty_attributes(@client.intake, intake_attr)
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
