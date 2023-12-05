module StateFile
  module Questions
    class LandingPageController < QuestionsController
      include StartIntakeConcern

      private
      def current_intake
        GlobalID.find(session[:state_file_intake])
      end
    end
  end
end
