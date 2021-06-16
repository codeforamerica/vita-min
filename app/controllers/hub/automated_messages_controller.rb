module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "admin"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      message_classes = [
        AutomatedMessage::GettingStarted,
        AutomatedMessage::SuccessfulSubmissionDropOff,
        AutomatedMessage::SuccessfulSubmissionOnlineIntake,
        AutomatedMessage::InProgressSurvey,
        AutomatedMessage::CompletionSurvey,
        AutomatedMessage::DocumentsReminderLink,
        AutomatedMessage::DropOffConfirmationMessage,
      ]

      @messages = message_classes.map do |message_class|
        message_class.new
      end
    end
  end
end
