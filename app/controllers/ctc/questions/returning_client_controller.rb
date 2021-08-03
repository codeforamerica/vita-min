module Ctc
  module Questions
    class ReturningClientController < QuestionsController
      include AnonymousIntakeConcern
      skip_before_action :set_current_step
      layout "intake"

      private

      def redirect_to_next_if_already_authenticated
        redirect_to next_path if current_client.present?
      end

      def form_class
        NullForm
      end

      def next_path
        nil
      end
    end
  end
end