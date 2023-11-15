module StateFile
  module Questions
    class LandingPageController < QuestionsController
      include StartIntakeConcern

      def update
        current_intake.save
        super
      end
    end
  end
end
