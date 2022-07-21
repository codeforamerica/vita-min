module Ctc
  module Questions
    class MainHomeController < QuestionsController
      include FirstPageOfCtcIntakeConcern

      private

      def illustration_path; end

      def next_path
        if current_intake.home_location_us_territory? || current_intake.home_location_foreign_address?
          return questions_use_gyr_path
        end
        super
      end
    end
  end
end
