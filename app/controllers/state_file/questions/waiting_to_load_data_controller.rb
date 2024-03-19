module StateFile
  module Questions
    class WaitingToLoadDataController < QuestionsController
      include EligibilityOffboardingConcern
      skip_before_action :set_current_step

      def edit
        raise ActionController::RoutingError, 'Not Found' unless params[:authorizationCode]
        binding.pry
        if current_intake.raw_direct_file_data.present?
          current_intake.update_df_data_imported_at
          return redirect_to next_path
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