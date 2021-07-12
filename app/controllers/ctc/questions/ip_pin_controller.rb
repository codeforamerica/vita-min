module Ctc
  module Questions
    class IpPinController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def edit
        render "ctc/questions/placeholder_question/edit"
      end
      
      def illustration_path; end
    end
  end
end
