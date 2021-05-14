module Hub
  class BulkActionForm < Form
    attr_accessor(
      :vita_partner_id,
      :assigned_user_id,
      :status,
      :message_body_en,
      :message_body_es,
      :note_body,
    )

    validate :no_missing_message_locales
    validates :message_body_en, :message_body_es,
              length: { maximum: 900, message: I18n.t("hub.bulk_actions.bulk_action_form.errors.message_length") },
              allow_blank: true

    def initialize(tax_return_selection, *args, **attributes)
      @tax_return_selection = tax_return_selection
      super(*args, **attributes)
    end

    private

    def no_missing_message_locales
      return if message_body_es.blank? && message_body_en.blank?

      locale_counts = @tax_return_selection.clients.locale_counts

      if locale_counts["es"].nonzero? && message_body_es.blank?
        errors.add(
          :message_body_es,
          I18n.t(
            "hub.bulk_actions.bulk_action_form.errors.missing_message_locale",
            missing_language: I18n.t("general.language_options.es")
          )
        )
      end

      if locale_counts["en"].nonzero? && message_body_en.blank?
        errors.add(
          :message_body_en,
          I18n.t(
            "hub.bulk_actions.bulk_action_form.errors.missing_message_locale",
            missing_language: I18n.t("general.language_options.en")
          )
        )
      end
    end
  end
end
