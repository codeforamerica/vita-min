require 'csv'

module StateFile
  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        @nyc_residency = current_intake.nyc_residency
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
