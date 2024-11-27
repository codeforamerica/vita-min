module StateFile
  module Questions
    class IdDonationsController < QuestionsController
      def self.show?(intake)
        false
      end

      private

      def next_path
        StateFile::Questions::IdReviewController.to_path_helper
      end
    end
  end
end
