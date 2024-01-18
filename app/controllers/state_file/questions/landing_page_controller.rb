module StateFile
  module Questions
    class LandingPageController < QuestionsController
      include StartIntakeConcern
      before_action :before_update, only: :update

      def before_update
        sign_out current_intake if current_intake
      end
    end
  end
end
