module Ctc
  module Questions
    class OverviewController < QuestionsController
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      private

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
