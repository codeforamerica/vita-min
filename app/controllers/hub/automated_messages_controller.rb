module Hub
  class AutomatedMessagesController < Hub::BaseController
    before_action :require_admin
    layout "hub"

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      Rails.application.eager_load!
      message_classes = AutomatedMessage::AutomatedMessage.descendants + [SurveyMessages::GyrCompletionSurvey, SurveyMessages::CtcExperienceSurvey]

      # TODO: These were not being used in the previous implementation of this code, so either figure out how to use them or delete them
      #   The issue is that different message classes take their args differently,
      message_params = {
        SurveyMessages::GyrCompletionSurvey => { survey_link: "https://fakecodeforamerica.co1.qualtrics.com" },
        SurveyMessages::CtcExperienceSurvey => { survey_link: "https://fakecodeforamerica.co1.qualtrics.com" },
        AutomatedMessage::DocumentsReminderLink => { body_args: { doc_type: "ID" } },
        AutomatedMessage::SaveCtcLetter => { body_args: { service_name: MultiTenantService.new(:ctc).service_name } },
        AutomatedMessage::UnmonitoredReplies => { support_email: Rails.configuration.email_from[:support][:gyr] },
      }

      automated_messages_and_mailers = message_classes.to_h do |klass|
        message = klass.new
        replaced_body = message.email_body.gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
        email = OutgoingEmail.new(to: "example@example.com", body: replaced_body, subject: message.email_subject, client: Client.new(intake: Intake::GyrIntake.new))
        [klass, OutgoingEmailMailer.user_message(outgoing_email: email)]
      end.to_h

      emails = {
        "UserMailer.assignment_email" => UserMailer.assignment_email(assigned_user: User.last, assigning_user: User.first, tax_return: TaxReturn.last, assigned_at: TaxReturn.last.updated_at),
        "VerificationCodeMailer.with_code" => VerificationCodeMailer.with(to: "example@example.com", locale: :en, service_type: :gyr, verification_code: '000000').with_code,
        "VerificationCodeMailer.no_match_found" => VerificationCodeMailer.no_match_found(to: "example@example.com", locale: :en, service_type: :gyr),
        "DiyIntakeEmailMailer.high_support_message" => DiyIntakeEmailMailer.high_support_message(diy_intake: DiyIntake.new(email_address: 'example@example.com', preferred_first_name: "Preferredfirstname"))
      }

      emails.merge(automated_messages_and_mailers).transform_values do |message|
        ActionMailer::Base.preview_interceptors.each do |interceptor|
          interceptor.previewing_email(message)
        end
        message
      end
    end
  end
end
