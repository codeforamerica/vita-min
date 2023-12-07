require 'csv'

module StateFile
  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      helper_method :county_options

      def county_options
        NySchoolDistricts.county_labels_for_select
      end

      private

      def illustration_path; end
    end
  end
end
