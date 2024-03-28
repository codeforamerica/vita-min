module StateFile
  module Questions
    class WaitingToLoadDataController < QuestionsController
      include EligibilityOffboardingConcern
      skip_before_action :set_current_step

      def edit
        raise ActionController::RoutingError, 'Not Found' unless params[:authorizationCode]
        return redirect_to next_path if current_intake.raw_direct_file_data.present?
        if [nil, "unfilled"].include?(current_intake.consented_to_terms_and_conditions)
          flash[:alert] = I18n.t("general.one_intake_at_a_time")
          redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: current_intake.state_code)
        end

        StateFile::ImportFromDirectFileJob.perform_later(authorization_code: params[:authorizationCode], intake: current_intake)
      end

      private

      def form_class
        NullForm
      end
    end
  end
end