module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "hub"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      @emails = {
        "UserMailer.assignment_email" => UserMailer.assignment_email(
          assigned_user: User.last,
          assigning_user: User.first,
          tax_return: TaxReturn.last,
          assigned_at: TaxReturn.last.updated_at
        ),
        "VerificationCodeMailer.with_code" => VerificationCodeMailer.with(to: "example@example.com", locale: :en, service_type: :gyr, verification_code: '000000').with_code,
        "VerificationCodeMailer.no_match_found" => VerificationCodeMailer.no_match_found(to: "example@example.com", locale: :en, service_type: :gyr),
        "DiyIntakeEmailMailer.high_support_message" => DiyIntakeEmailMailer.high_support_message(
          diy_intake: DiyIntake.last,
        )
      }

      messages = [
        [AutomatedMessage::SuccessfulSubmissionDropOff, {}],
        [AutomatedMessage::SuccessfulSubmissionOnlineIntake, {}],
        [SurveyMessages::GyrCompletionSurvey, {}],
        [SurveyMessages::CtcExperienceSurvey, {}],
        [AutomatedMessage::DocumentsReminderLink, {}],
        [AutomatedMessage::EfileAcceptance, {}],
        [AutomatedMessage::EfilePreparing, {}],
        [AutomatedMessage::EfileRejected, {}],
        [AutomatedMessage::EfileRejectedAndCancelled, {}],
        [AutomatedMessage::EfileFailed, {}],
        [AutomatedMessage::CtcGettingStarted, {}],
        [AutomatedMessage::ClosingSoon, {}],
        [AutomatedMessage::SaveCtcLetter, {}],
        [AutomatedMessage::ContactInfoChange, {}],
        [AutomatedMessage::FirstNotReadyReminder, {}],
        [AutomatedMessage::SecondNotReadyReminder, {}],
        [AutomatedMessage::InformOfFraudHold, {}],
        [AutomatedMessage::NewPhotosRequested, {}],
        [AutomatedMessage::VerificationAttemptDenied, {}],
        [AutomatedMessage::Ctc2022OpenMessage, {}],
        [AutomatedMessage::PuertoRicoOpenMessage, {}],
        [AutomatedMessage::IntercomForwarding, {}],
        [AutomatedMessage::UnmonitoredReplies, {}],
        [AutomatedMessage::InProgress, {}],
      ]

      @messages = messages.map do |message|
        message_class = message[0]
        args = message[1]
        args.present? ? message_class.new(args) : message_class.new
      end
    end
  end
end
