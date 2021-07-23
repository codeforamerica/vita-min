module Ctc
  module Questions
    class ConfirmInformationController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"
      
      def illustration_path
        "successfully-submitted.svg"
      end
    end
  end
end
