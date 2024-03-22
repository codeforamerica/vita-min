module StateFile
  module Questions
    class WaitingToLoadDataController < QuestionsController
      include EligibilityOffboardingConcern
      skip_before_action :set_current_step

      def edit
        raise ActionController::RoutingError, 'Not Found' unless params[:authorizationCode]
        return redirect_to next_path if current_intake.raw_direct_file_data.present?
        return redirect_to IntakeLoginsController.to_path_helper(action: :new, us_state: "us") unless current_intake.consented_to_terms_and_conditions

        StateFile::ImportFromDirectFileJob.perform_later(authorization_code: params[:authorizationCode], intake: current_intake)
      end

      private

      def form_class
        NullForm
      end
    end
  end
end