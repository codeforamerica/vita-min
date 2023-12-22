require 'csv'

module StateFile
  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      helper_method :county_options

      def county_options
        NySchoolDistricts.county_labels_for_select
      end

      def next_path
        # If the current school district is not in the chosen county, the next step is school district selection
        residence_county = current_intake.residence_county
        school_district_options = NySchoolDistricts.county_school_districts_labels_for_select(residence_county)
        school_district_names = school_district_options.pluck(1)
        if school_district_names.include?(current_intake.school_district)
          super
        else
          step_for_next_path = StateFile::Questions::NySchoolDistrictController
          options = { us_state: params[:us_state], action: step_for_next_path.navigation_actions.first }
          if params[:return_to_review]
            options[:return_to_review] = 'y'
          end
          step_for_next_path.to_path_helper(options)
        end
      end

      private

      def illustration_path; end
    end
  end
end
