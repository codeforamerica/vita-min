module CampaignMessage
  class DiyFollowupSurvey < CampaignMessage
    def self.message_name
      'campaign_messages.diy_followup_survey'.freeze
    end

    def email_subject(contact:, **args)
      I18n.t("campaign_messages.diy_followup_survey.email.subject", **vars(contact), **args)
    end

    def email_body(contact:, **args)
      I18n.t("campaign_messages.diy_followup_survey.email.body_html", **vars(contact), **args)
    end
  end
end