require 'csv'

module StateFile
  NYC_COUNTIES = [
    "Bronx",
    "Kings (Brooklyn)",
    "Manhattan (see New York)",
    "New York (Manhattan)",
    "Queens",
    "Richmond (Staten Island)"
  ].freeze

  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        @nyc_residency = current_intake.nyc_residency
        nyc_residency_full_year = @nyc_residency == "full_year"
        @permitted_counties = NySchoolDistricts.county_labels.filter { |c| NYC_COUNTIES.include?(c) != nyc_residency_full_year }
        super
      end

      private

      def next_path
        options = { us_state: params[:us_state], action: :edit }
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NySchoolDistrictController.to_path_helper(options)
      end
    end
  end
end
