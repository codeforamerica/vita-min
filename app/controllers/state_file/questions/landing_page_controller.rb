module StateFile
  module Questions
    class LandingPageController < QuestionsController
      include StartIntakeConcern
      before_action :before_update, only: :update

      def before_update
        StateFileBaseIntake::STATE_CODES.each do |state_code|
          intake = send("current_state_file_#{state_code}_intake")
          sign_out intake if intake
        end
      end
    end
  end
end
