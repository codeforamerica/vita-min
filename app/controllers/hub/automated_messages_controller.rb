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
          [AutomatedMessage::InProgressSurvey, {}],
          [AutomatedMessage::CompletionSurvey, {}],
          [AutomatedMessage::CtcExperienceSurvey, {}],
          [AutomatedMessage::DocumentsReminderLink, {}],
          [AutomatedMessage::EfileAcceptance, {}],
          [AutomatedMessage::EfilePreparing, {}],
          [AutomatedMessage::EfileRejected, {}],
          [AutomatedMessage::EfileFailed, {}],
          [AutomatedMessage::CtcGettingStarted, {}],
          [AutomatedMessage::ClosingSoon, {}],
          [AutomatedMessage::SaveCtcLetter, {}]
      ]

      @messages = messages.map do |message|
        message_class = message[0]
        args = message[1]
        args.present? ? message_class.new(args) : message_class.new
      end
    end
  end
end
