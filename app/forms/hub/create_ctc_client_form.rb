module Hub
  class CreateCtcClientForm < ClientForm
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
                       :with_unhoused_navigator,
                       :bank_account_number,
                       :bank_routing_number,
                       :bank_account_type,
                       :bank_name
    set_attributes_for :confirmation,
                       :bank_account_number_confirmation,
                       :bank_routing_number_confirmation
    attr_accessor :bank_routing_number_confirmation, :bank_account_number_confirmation, :client
    # See parent ClientForm for additional validations.
    validates :vita_partner_id, presence: true, allow_blank: false
    validates :signature_method, presence: true
    after_save :send_confirmation_message, :send_mixpanel_data
    validates_confirmation_of :bank_routing_number
    validates_confirmation_of :bank_account_number
    validates_presence_of :bank_account_number_confirmation, if: :bank_account_number
    validates_presence_of :bank_routing_number_confirmation, if: :bank_routing_number
    validates_presence_of :bank_account_number
    validates_presence_of :bank_routing_number
    def required_dependents_attributes
      [:birth_date, :first_name, :last_name, :relationship].freeze
    end

    def save(current_user)
      @current_user = current_user
      run_callbacks :save do
        return false unless valid?

        @client = Client.create!(
          vita_partner_id: attributes_for(:intake)[:vita_partner_id],
          intake_attributes: attributes_for(:intake).merge(default_attributes).merge(dependents_attributes: formatted_dependents_attributes).merge(visitor_id: SecureRandom.hex(26)),
          tax_returns_attributes: [tax_return_attributes]
        )
      end
    end

    private

    def send_confirmation_message
      locale = client.intake.preferred_interview_language == "es" ? "es" : "en"

      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: client,
        sms_body: I18n.t("drop_off_confirmation_message.sms.body", locale: locale),
        email_body: I18n.t("drop_off_confirmation_message.email.body", locale: locale),
        subject: I18n.t("drop_off_confirmation_message.email.subject", locale: locale),
        locale: locale
      )
    end

    def send_mixpanel_data
      client.tax_returns.each do |tax_return|
        MixpanelService.send_event(
          event_id: @client.intake.visitor_id,
          event_name: "drop_off_submitted",
          data: MixpanelService.data_from([client, tax_return, @current_user])
        )
      end
    end

    def default_attributes
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
        is_ctc: true,
        certification_level: :basic,
        status: :prep_ready_for_prep,
        service_type: :drop_off
      }
    end
  end
end
