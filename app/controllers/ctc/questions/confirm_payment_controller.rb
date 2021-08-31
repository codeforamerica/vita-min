module Ctc
  module Questions
    class ConfirmPaymentController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
