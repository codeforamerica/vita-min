module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "admin"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      efile_error = EfileError.where(expose: true).order("RANDOM()").first
      messages = [
          [AutomatedMessage::GettingStarted, {}],
          [AutomatedMessage::SuccessfulSubmissionDropOff, {}],
          [AutomatedMessage::SuccessfulSubmissionOnlineIntake, {}],
          [AutomatedMessage::InProgressSurvey, {}],
          [AutomatedMessage::CompletionSurvey, {}],
          [AutomatedMessage::DocumentsReminderLink, {}],
          [AutomatedMessage::EfileAcceptance, {}],
          [AutomatedMessage::EfilePreparing, {}],
          [AutomatedMessage::EfileRejected, { error_code: efile_error.code, error_message: efile_error.message }],
      ]

      @messages = messages.map do |message|
        message_class = message[0]
        args = message[1]
        args.present? ? message_class.new(args) : message_class.new
      end
    end
  end
end
