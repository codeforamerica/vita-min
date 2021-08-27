module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "admin"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      messages = [
          [AutomatedMessage::GettingStarted, {}],
          [AutomatedMessage::SuccessfulSubmissionDropOff, {}],
          [AutomatedMessage::SuccessfulSubmissionOnlineIntake, {}],
          [AutomatedMessage::InProgressSurvey, {}],
          [AutomatedMessage::CompletionSurvey, {}],
          [AutomatedMessage::DocumentsReminderLink, {}],
          [AutomatedMessage::EfileAcceptance, {}],
          [AutomatedMessage::EfilePreparing, {}],
          [AutomatedMessage::EfileRejected, {}],
          [AutomatedMessage::EfileFailed, {}],
          [AutomatedMessage::CtcGettingStarted, {}],
      ]

      @messages = messages.map do |message|
        message_class = message[0]
        args = message[1]
        args.present? ? message_class.new(args) : message_class.new
      end
    end
  end
end
