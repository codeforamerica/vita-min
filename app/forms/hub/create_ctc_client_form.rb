module Hub
  class CreateCtcClientForm < ClientForm
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
                       :primary_last_four_ssn,
                       :spouse_last_four_ssn,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :vita_partner_id,
                       :signature_method,
                       :with_general_navigator,
                       :with_incarcerated_navigator,
                       :with_limited_english_navigator,
                       :with_unhoused_navigator
    set_attributes_for :tax_return, :service_type
    attr_accessor :tax_returns, :tax_returns_attributes, :client, :intake

    # See parent ClientForm for additional validations.
    validates :vita_partner_id, presence: true, allow_blank: false
    validates :signature_method, presence: true

    def initialize(attributes = {})
      @tax_returns = TaxReturn.filing_years.map { |year| TaxReturn.new(year: year) }
      super(attributes)
    end

    def save(current_user)
      return false unless valid?

      @client = Client.create!(
        is_ctc: true,
        vita_partner_id: attributes_for(:intake)[:vita_partner_id],
        intake_attributes: attributes_for(:intake).merge(needs_help_attributes).merge(visitor_id: SecureRandom.hex(26)),
        tax_returns_attributes: [tax_return_attributes]
      )

      locale = @client.intake.preferred_interview_language == "es" ? "es" : "en"
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: @client,
        sms_body: I18n.t("drop_off_confirmation_message.sms.body", locale: locale),
        email_body: I18n.t("drop_off_confirmation_message.email.body", locale: locale),
        subject: I18n.t("drop_off_confirmation_message.email.subject", locale: locale),
        locale: locale
      )

      @client.tax_returns.each do |tax_return|
        MixpanelService.send_event(
          event_id: @client.intake.visitor_id,
          event_name: "drop_off_submitted",
          data: MixpanelService.data_from([@client, tax_return, current_user])
        )
      end
    end

    def self.permitted_params
      CreateClientForm.attribute_names
    end

    private

    def needs_help_attributes
      {
        needs_help_2020: :yes,
        needs_help_2019: :no,
        needs_help_2018: :no,
        needs_help_2017: :no,
      }
    end

    def tax_return_attributes
      {
        year: 2020,
        is_hsa: 0,
        certification_level: :basic,
        status: :prep_ready_for_prep,
        service_type: :drop_off
      }
    end
  end
end
