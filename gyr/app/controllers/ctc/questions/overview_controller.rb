module Ctc
  module Questions
    class OverviewController < QuestionsController
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      def edit
        return redirect_to root_path unless open_for_ctc_intake?

        super
      end

      private


      def after_update_success
        send_mixpanel_event(event_name: "ctc_started_flow")
      end

      def illustration_path
        "wages.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end
