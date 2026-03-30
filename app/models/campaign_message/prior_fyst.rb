module CampaignMessage
  class PriorFyst < CampaignMessage
    include Rails.application.routes.url_helpers

    def self.message_name
      'campaign_messages.prior_fyst'.freeze
    end

    def email_subject(contact:, **args)
      I18n.t("campaign_messages.prior_fyst.email.subject", **vars(contact), **args)
    end

    def email_body(contact:, **args)
      args[:url] = url_for(
        host: MultiTenantService.new(:gyr).host,
        controller: "/redirects",
        action: "fyst_outreach",
        locale: contact.locale
      )

      I18n.t("campaign_messages.prior_fyst.email.body_html", **vars(contact), **args)
    end

    def sms_body(contact:, **args)
      I18n.t("campaign_messages.prior_fyst.sms", **vars(contact), **args)
    end
  end
end