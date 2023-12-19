require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      helper_method :school_district_options

      def school_district_options
        NySchoolDistricts.county_school_districts_labels_for_select(current_intake.residence_county)
      end

      private

      def form_params
        school_district_from_params = params[:state_file_ny_school_district_form][:school_district]
        school_district_number = NySchoolDistricts.combined_name_to_code_number_map(current_intake.residence_county)[school_district_from_params]
        original_name = NySchoolDistricts.combined_name_to_original_name_map(current_intake.residence_county)[school_district_from_params]
        super.merge(
          school_district: original_name,
          school_district_number: school_district_number.to_i
        )
      end

      def illustration_path; end
    end
  end
end
