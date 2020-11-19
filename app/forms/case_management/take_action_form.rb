module CaseManagement
  class TakeActionForm < Form
    attr_accessor :status, :locale, :message_body, :contact_method, :internal_note_body

    def initialize(client, *args, **attributes)
      @client = client
      super(*args, **attributes)
    end

    def language_difference_help_text
      if @client.intake.preferred_interview_language.present? && (locale != @client.intake.preferred_interview_language)
        I18n.t(
          "case_management.tax_returns.edit_status.language_mismatch",
          interview_language: language_label(@client.intake.preferred_interview_language)
        )
      end
    end

    def contact_method_options
      methods = []
      methods += [{ value: "email", label: "Email message" }] if @client.intake.email_notification_opt_in_yes?
      methods += [{ value: "text_message", label: "Text message" }] if @client.intake.sms_notification_opt_in_yes?
      methods
    end

    def contact_method_help_text
      if @client.intake.email_notification_opt_in_yes? ^ @client.intake.sms_notification_opt_in_yes? # ^ = XOR operator
        preferred = @client.intake.email_notification_opt_in_yes? ? I18n.t("general.email") : I18n.t("general.text_message")
        other_method = preferred == I18n.t("general.text_message") ? I18n.t("general.email") : I18n.t("general.text_message")
        I18n.t(
          "case_management.tax_returns.edit_status.prefers_one_contact_method",
          preferred: preferred.downcase,
          other_method: other_method.downcase
        )
      end
    end

    private

    def language_label(key)
      I18n.t("general.language_options.#{key}")
    end
  end
end
