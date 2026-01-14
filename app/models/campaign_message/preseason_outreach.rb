module CampaignMessage
  class PreseasonOutreach < CampaignMessage
    def self.name
      'messages.preseason_outreach'.freeze
    end

    def sms_body(**args)
      # I18n.t("messages.preseason_outreach.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.preseason_outreach.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.preseason_outreach.email.body", **args)
    end
  end
end