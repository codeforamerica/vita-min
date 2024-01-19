module StateFile
  module Questions
    class LandingPageController < QuestionsController
      include StartIntakeConcern
      before_action :clear_existing_intakes, only: :update

      def clear_existing_intakes
        sign_out current_state_file_az_intake if current_state_file_az_intake.present?
        sign_out current_state_file_ny_intake if current_state_file_ny_intake.present?
      end
    end
  end
end
