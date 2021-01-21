module Hub
  class TakeActionForm < Form
    attr_accessor :tax_return,
                  :tax_return_id, 
                  :tax_returns, 
                  :status, 
                  :locale, 
                  :message_body, 
                  :contact_method, 
                  :internal_note_body, 
                  :action_list,
                  :current_user,
                  :client
    validates_presence_of :status
    validate :belongs_to_client
    validate :status_has_changed

    def initialize(client, current_user, *args, **attributes)
      @client = client
      @current_user = current_user
      @tax_returns = client.tax_returns.order(year: :asc)
      @action_list = []
      super(*args, **attributes)

      set_default_locale if @locale.blank?
      set_default_message_body if @message_body.nil?
      set_default_contact_method if @contact_method.nil?
    end

    def language_difference_help_text
      if client.intake.preferred_interview_language.present? && (locale != @client.intake.preferred_interview_language)
        I18n.t(
          "hub.clients.edit_take_action.language_mismatch",
          interview_language: language_label(@client.intake.preferred_interview_language)
        )
      end
    end

    def contact_method_options
      methods = []
      methods << { value: "email", label: I18n.t("general.email") } if client.intake.email_notification_opt_in_yes?
      methods << { value: "text_message", label: I18n.t("general.text_message") } if client.intake.sms_notification_opt_in_yes?

      # We should not have an expected case where a client hasn't opted in, but it might occur rarely or on demo
      # We don't want this form to fail silently if that is the case.
      raise StandardError.new("Client has not opted in to any communications") unless methods.present?

      methods
    end

    def contact_method_help_text
      if client.intake.email_notification_opt_in_yes? ^ client.intake.sms_notification_opt_in_yes? # ^ = XOR operator
        preferred = client.intake.email_notification_opt_in_yes? ? I18n.t("general.email") : I18n.t("general.text_message")
        other_method = preferred == I18n.t("general.text_message") ? I18n.t("general.email") : I18n.t("general.text_message")
        I18n.t(
          "hub.clients.edit_take_action.prefers_one_contact_method",
          preferred: preferred.downcase,
          other_method: other_method.downcase
        )
      end
    end

    def self.permitted_params
      [:tax_return_id, :status, :locale, :message_body, :contact_method, :internal_note_body]
    end

    def tax_return
      @tax_return ||= client.tax_returns.find_by(id: tax_return_id)
    end

    private

    def language_label(key)
      I18n.t("general.language_options.#{key}")
    end

    def set_default_message_body
      @message_body = "" and return unless status.present?

      template = TaxReturnStatus.message_template_for(status, locale)
      @message_body = ReplacementParametersService.new(body: template, client: client, preparer: current_user, locale: locale).process
    end

    def set_default_contact_method
      default = "email"
      prefers_sms_only = client.intake.sms_notification_opt_in_yes? && client.intake.email_notification_opt_in_no?
      @contact_method = prefers_sms_only ? "text_message" : default
    end

    def set_default_locale
      @locale = client.intake.locale
    end

    def status_has_changed
      errors.add(:status, I18n.t("forms.errors.status_must_change")) if status == tax_return&.status
    end

    def belongs_to_client
      errors.add(:tax_return_id, I18n.t("forms.errors.tax_return_belongs_to_client")) unless tax_return.present?
    end
  end
end
