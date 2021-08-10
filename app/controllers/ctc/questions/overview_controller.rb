module Ctc
  module Questions
    class OverviewController < QuestionsController
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_started_flow")
      end

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
