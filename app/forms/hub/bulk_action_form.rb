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
    validate :bulk_tax_return_update_present
    validates :message_body_en, :message_body_es,
              length: { maximum: 900, message: I18n.t("hub.bulk_actions.bulk_action_form.errors.message_length") },
              allow_blank: true

    def initialize(tax_return_selection, *args, **attributes)
      @tax_return_selection = tax_return_selection
      super(*args, **attributes)
      set_default_message_body("es") if @message_body_es.blank?
      set_default_message_body("en") if @message_body_en.blank?
    end

    def assigned_user
      return if assigned_user_id.nil? || assigned_user_id.to_i.zero?

      @assigned_user ||= User.find_by_id(assigned_user_id)
    end

    private

    def set_default_message_body(locale)
      if (locale == "es")
        @message_body_es = "" and return unless status.present?
        @message_body_es = TaxReturnStatus.message_template_for(status, locale)
      else
        @message_body_en = "" and return unless status.present?
        @message_body_en = TaxReturnStatus.message_template_for(status, locale)
      end
    end

    def bulk_tax_return_update_present
      if assigned_user_id == BulkTaxReturnUpdate::KEEP && status == BulkTaxReturnUpdate::KEEP
        errors.add(:status, I18n.t("hub.bulk_actions.bulk_action_form.errors.missing_bulk_tax_return_update"))
      end
    end

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
