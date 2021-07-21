module Ctc
  module Questions
    class IpPinController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        render "ctc/questions/placeholder_question/edit"
      end
      
      def illustration_path; end
    end
  end
end
