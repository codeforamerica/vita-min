class SendClientCtcExperienceSurveyJob < ApplicationJob
  def perform(client)
    client.with_lock do
      unless client.ctc_experience_survey_variant.present?
        random_variant = 1 + rand(3)
        client.update!(ctc_experience_survey_variant: random_variant)
      end
    end

    SurveySender.send_survey(
      client,
      :ctc_experience_survey_sent_at,
      AutomatedMessage::CtcExperienceSurvey
    )
  end
end
