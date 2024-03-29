module StateFile
  module Questions
    class LandingPageController < QuestionsController

      def create
        # Start a new session...
        StateFileBaseIntake::STATE_CODES.each do |state_code|
          intake = send("current_state_file_#{state_code}_intake")
          sign_out intake if intake
        end
        super
      end

      def update
        # Go to existing session
        controller = intake.controller_for_current_step
        to_path = controller.to_path_helper(
          action: controller.navigation_actions.first,
          us_state: intake.state_code
        )
        redirect_to to_path
      end

      def current_intake
        @intake ||= question_navigator.intake_class.new(
          visitor_id: cookies.encrypted[:visitor_id],
          source: session[:source],
          referrer: session[:referrer]
        )
      end
    end
  end
end
