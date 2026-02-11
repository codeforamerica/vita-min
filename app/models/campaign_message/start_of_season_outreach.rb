module CampaignMessage
  class StartOfSeasonOutreach < CampaignMessage
    def self.name
      'messages.start_of_season_outreach'.freeze
    end

    def sms_body(contact:, **args)
      I18n.t("messages.start_of_season_outreach.sms", **vars(contact), **args)
    end

    def email_subject(contact:, **args)
      I18n.t("messages.start_of_season_outreach.email.subject", **vars(contact), **args)
    end

    def email_body(contact:, **args)
      I18n.t("messages.start_of_season_outreach.email.body", **vars(contact), **args)
    end
  end
end