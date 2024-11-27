module StateFile
  module Questions
    class IdDonationsController < QuestionsController
      def self.show?(intake)
        false
      end

      private

    end
  end
end
