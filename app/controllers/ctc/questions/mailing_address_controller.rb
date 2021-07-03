module Ctc
  module Questions
    class MailingAddressController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def edit
        render "ctc/questions/placeholder_question/edit"
      end
    end
  end
end