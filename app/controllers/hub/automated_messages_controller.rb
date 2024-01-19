module Hub
  class AutomatedMessagesController < Hub::BaseController
    before_action :require_admin
    layout "hub"

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      automated_messages = [
        [AutomatedMessage::SuccessfulSubmissionDropOff, {}],
        [AutomatedMessage::SuccessfulSubmissionOnlineIntake, {}],
        [SurveyMessages::GyrCompletionSurvey, { survey_link: "https://fakecodeforamerica.co1.qualtrics.com" }],
        [SurveyMessages::CtcExperienceSurvey, { survey_link: "https://fakecodeforamerica.co1.qualtrics.com" }],
        [AutomatedMessage::DocumentsReminderLink, { body_args: { doc_type: "ID" } }],
        [AutomatedMessage::EfileAcceptance, {}],
        [AutomatedMessage::EfilePreparing, {}],
        [AutomatedMessage::EfileRejected, {}],
        [AutomatedMessage::EfileRejectedAndCancelled, {}],
        [AutomatedMessage::EfileFailed, {}],
        [AutomatedMessage::CtcGettingStarted, {}],
        [AutomatedMessage::ClosingSoon, {}],
        [AutomatedMessage::SaveCtcLetter, { body_args: { service_name: MultiTenantService.new(:ctc).service_name } }],
        [AutomatedMessage::ContactInfoChange, {}],
        [AutomatedMessage::FirstNotReadyReminder, {}],
        [AutomatedMessage::SecondNotReadyReminder, {}],
        [AutomatedMessage::InformOfFraudHold, {}],
        [AutomatedMessage::NewPhotosRequested, {}],
        [AutomatedMessage::VerificationAttemptDenied, {}],
        [AutomatedMessage::Ctc2022OpenMessage, {}],
        [AutomatedMessage::PuertoRicoOpenMessage, {}],
        [AutomatedMessage::IntercomForwarding, {}],
        [AutomatedMessage::UnmonitoredReplies, { support_email: Rails.configuration.email_from[:support][:gyr] }],
        [AutomatedMessage::InProgress, {}],
      ]

      automated_messages_and_mailers = automated_messages.map do |m|
        message = m[0].new
        replaced_body = message.email_body.gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
        email = OutgoingEmail.new(to: "example@example.com", body: replaced_body, subject: message.email_subject, client: Client.new(intake: Intake::GyrIntake.new))
        [m[0], OutgoingEmailMailer.user_message(outgoing_email: email)]
      end.to_h

      emails = {
        "UserMailer.assignment_email" => UserMailer.assignment_email(assigned_user: User.last, assigning_user: User.first, tax_return: TaxReturn.last, assigned_at: TaxReturn.last.updated_at),
        "VerificationCodeMailer.with_code" => VerificationCodeMailer.with(to: "example@example.com", locale: :en, service_type: :gyr, verification_code: '000000').with_code,
        "VerificationCodeMailer.with_code_fyst" => VerificationCodeMailer.with(to: "example@example.com", locale: :en, service_type: :statefile, verification_code: '000000').with_code_fyst,
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
