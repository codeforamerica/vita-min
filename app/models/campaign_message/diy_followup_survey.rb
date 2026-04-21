module CampaignMessage
  class DiyFollowupSurvey < CampaignMessage
    include Rails.application.routes.url_helpers

    def self.message_name
      'campaign_messages.diy_followup_survey'.freeze
    end

    def email_subject(contact:, **args)
      I18n.t("campaign_messages.diy_followup_survey.email.subject", **vars(contact), **args)
    end

    def email_body(contact:, **args)
      args[:survey_link] = url_for(
          host: MultiTenantService.new(:gyr).host,
          controller: "/redirects",
          action: "diy_survey"
        )

      I18n.t("campaign_messages.diy_followup_survey.email.body_html", **vars(contact), **args)
    end

    def self.max_sends_per_contact
      2
    end
  end
end