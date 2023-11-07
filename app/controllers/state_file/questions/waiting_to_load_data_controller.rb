module StateFile
  module Questions
    class WaitingToLoadDataController < QuestionsController
      def edit
        StateFile::ImportFromDirectFileJob.perform_later(token: params[:authorization_token], intake: current_intake)
      end

      private

      def form_class
        NullForm
      end
    end
  end
end