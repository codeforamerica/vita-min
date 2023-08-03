module StateFile
  module Questions
    class AllInfoController < QuestionsController
      layout "intake"

      private

      def illustration_path
        "wages.svg"
      end

      # def after_update_success
      #   session[:intake_id] = current_intake.id
      # end
      #
      # def current_intake
      #   @intake ||= Intake.new(
      #     visitor_id: cookies.encrypted[:visitor_id],
      #     source: session[:source],
      #     referrer: session[:referrer]
      #   )
      # end
    end
  end
end
