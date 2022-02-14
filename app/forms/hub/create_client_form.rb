module Hub
  class CreateClientForm < ClientForm
    include FormAttributes
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_last_name,
                       :preferred_name,
                       :preferred_interview_language,
                       :married,
                       :separated,
                       :widowed,
                       :lived_with_spouse,
                       :divorced,
                       :divorced_year,
                       :separated_year,
                       :widowed_year,
                       :email_address,
                       :phone_number,
                       :sms_phone_number,
                       :street_address,
                       :city,
                       :state,
                       :state_of_residence,
                       :zip_code,
                       :primary_ssn,
                       :spouse_ssn,
                       :primary_tin_type,
                       :spouse_tin_type,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :vita_partner_id,
                       :needs_help_2021,
                       :needs_help_2020,
                       :needs_help_2019,
                       :needs_help_2018,
                       :signature_method,
                       :with_general_navigator,
                       :with_incarcerated_navigator,
                       :with_limited_english_navigator,
                       :with_unhoused_navigator
    set_attributes_for :tax_return, :service_type
    set_attributes_for :confirmation, :primary_ssn_confirmation, :spouse_ssn_confirmation
    attr_accessor :tax_returns, :tax_returns_attributes, :client, :intake

    # See parent ClientForm for additional validations.
    validates :vita_partner_id, presence: true, allow_blank: false
    validates :signature_method, presence: true
    validate :tax_return_required_fields_valid
    validate :at_least_one_tax_return_present
    validates :state_of_residence, inclusion: { in: States.keys }
    validates :preferred_interview_language, presence: true, allow_blank: false
    validates :primary_tin_type, presence: true
    validates_confirmation_of :primary_ssn
    validates_presence_of :primary_ssn_confirmation, if: :primary_ssn
    validates_presence_of :spouse_ssn_confirmation, if: :spouse_ssn
    validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
    validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin"}
    validates_confirmation_of :spouse_ssn, if: -> { filing_joint == "yes" }
    validates :spouse_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include?(spouse_tin_type) && filing_joint == "yes"}
    validates :spouse_ssn, individual_taxpayer_identification_number: true, if: -> { spouse_tin_type == "itin" && filing_joint == "yes" }

    def initialize(attributes = {})
      @tax_returns = TaxReturn.filing_years.map { |year| TaxReturn.new(year: year) }
      super(attributes)
    end

    def save(current_user)
      return false unless valid?

      @client = Client.create!(
        vita_partner_id: attributes_for(:intake)[:vita_partner_id],
        intake_attributes: attributes_for(:intake).merge(default_intake_attributes),
        tax_returns_attributes: @tax_returns_attributes.map { |_, v| create_tax_return_for_year?(v[:year]) ? attributes_for(:tax_return).merge(v) : nil }.compact
      )

      locale = @client.intake.preferred_interview_language == "es" ? "es" : "en"
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: @client,
        message: AutomatedMessage::SuccessfulSubmissionDropOff,
        locale: locale
      )

      @client.tax_returns.each do |tax_return|
        tax_return.transition_to(:prep_ready_for_prep)
        MixpanelService.send_event(
          distinct_id: @client.intake.visitor_id,
          event_name: "drop_off_submitted",
          data: MixpanelService.data_from([@client, tax_return, current_user])
        )
      end
    end

    def self.permitted_params
      params = CreateClientForm.attribute_names
      params.delete(:tax_returns_attributes)
      params.push(tax_returns_attributes: {})
    end

    private

    def default_intake_attributes
      {
        type: "Intake::GyrIntake",
        visitor_id: SecureRandom.hex(26),
        primary_consented_to_service: "yes",
        primary_consented_to_service_at: DateTime.now,
        completed_at: DateTime.now
      }
    end

    def create_tax_return_for_year?(year)
      attributes_for(:intake)["needs_help_#{year}".to_sym] == "yes"
    end

    def tax_return_required_fields_valid
      required_attrs = [:certification_level]
      missing_attrs = []
      @tax_returns_attributes&.each do |_, v|
        next unless create_tax_return_for_year?(v[:year])

        values = HashWithIndifferentAccess.new(v)
        required_attrs.each { |attr| missing_attrs.push(attr) if values[attr].blank? }
      end
      if missing_attrs.uniq.present?
        error_message = I18n.t("forms.errors.tax_returns", attrs: missing_attrs.uniq.map { |field| I18n.t("forms.errors.tax_returns_attributes.#{field}") }.join(", "))
        errors.add(:tax_returns_attributes, error_message)
      end
    end

    def at_least_one_tax_return_present
      tax_return_count = 0
      @tax_returns_attributes&.each do |_, v|
        tax_return_count += 1 if create_tax_return_for_year?(v[:year])
      end
      errors.add(:tax_returns_attributes, I18n.t("forms.errors.at_least_one_year")) unless tax_return_count.positive?
    end
  end
end
