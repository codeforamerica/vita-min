module Ctc
  module Questions
    class MainHomeController < QuestionsController
      include FirstPageOfCtcIntakeConcern

      private

      def illustration_path; end

      def next_path
        if current_intake.home_location_us_territory? || current_intake.home_location_foreign_address?
          questions_use_gyr_path
        elsif current_intake.home_location_puerto_rico? && !current_intake.puerto_rico_filing?
          offboarding_cant_use_getctc_pr_path
        else
          super
        end
      end
    end
  end
end
