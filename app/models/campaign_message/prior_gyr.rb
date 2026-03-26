module CampaignMessage
  class PriorGyr < CampaignMessage
    include Rails.application.routes.url_helpers

    def self.message_name
      'campaign_messages.prior_gyr'.freeze
    end

    def email_subject(contact:, **args)
      I18n.t("campaign_messages.prior_gyr.email.subject", **vars(contact), **args)
    end

    def email_body(contact:, **args)
      I18n.t("campaign_messages.prior_gyr.email.body_html", **vars(contact), **args)
    end

    def sms_body(contact:, **args)
      I18n.t("campaign_messages.prior_gyr.sms", **vars(contact), **args)
    end
  end
end