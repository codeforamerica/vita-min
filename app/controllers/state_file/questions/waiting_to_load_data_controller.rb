module StateFile
  module Questions
    class WaitingToLoadDataController < QuestionsController
      def edit
        raise ActionController::RoutingError, 'Not Found' unless params[:authorizationCode]
        return redirect_to next_path if current_intake.raw_direct_file_data.present?

        StateFile::ImportFromDirectFileJob.perform_later(token: params[:authorizationCode], intake: current_intake)
      end

      private

      def form_class
        NullForm
      end
    end
  end
end