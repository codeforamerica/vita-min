module StateFile
  module Questions
    class MdPermanentlyDisabledController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.state_file1099_rs.length.positive?
      end
    end
  end
end
