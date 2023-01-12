module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "hub"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      messages = [
          [AutomatedMessage::GettingStarted, {}],
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
          [AutomatedMessage::UnmonitoredReplies, {}]
      ]

      @messages = messages.map do |message|
        message_class = message[0]
        args = message[1]
        args.present? ? message_class.new(args) : message_class.new
      end
    end
  end
end
