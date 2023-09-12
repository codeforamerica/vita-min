module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :require_admin
    layout "hub"

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      gyr_client = Client.new(intake: Intake::GyrIntake.new(preferred_name: "PreferredFirstName"), tax_returns: [TaxReturn.new(assigned_user: User.new(name: "AssignedUser", timezone: "America/New_York", role_type: AdminRole::TYPE), updated_at: Time.now)], id: "98765", vita_partner: Organization.new(name: "AssignedOrganization"))
      ctc_client = Client.new(intake: Intake::CtcIntake.new(product_year: Rails.configuration.product_year), tax_returns: [TaxReturn.new(year: Rails.configuration.product_year - 1)])
      automated_messages = [
        [AutomatedMessage::SuccessfulSubmissionDropOff, {}],
        [AutomatedMessage::SuccessfulSubmissionOnlineIntake, {}],
        [SurveyMessages::GyrCompletionSurvey, { survey_link: SurveyMessages::GyrCompletionSurvey.survey_link(gyr_client) }],
        [SurveyMessages::CtcExperienceSurvey, { survey_link: SurveyMessages::CtcExperienceSurvey.survey_link(ctc_client) }],
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
        replacement_args = {
          body: message.email_body(**m[1]),
          client: gyr_client,
          preparer: User.first,
          tax_return: gyr_client.tax_returns.first }
        replaced_body = ReplacementParametersService.new(**replacement_args).process
        email = OutgoingEmail.new(to: "example@example.com", body: replaced_body, subject: message.email_subject, client: gyr_client)
        [m[0], OutgoingEmailMailer.user_message(outgoing_email: email)]
      end.to_h

      emails = {
        "UserMailer.assignment_email" => UserMailer.assignment_email(assigned_user: User.first, assigning_user: gyr_client.tax_returns.first.assigned_user, tax_return: gyr_client.tax_returns.first, assigned_at: gyr_client.tax_returns.first.updated_at),
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
