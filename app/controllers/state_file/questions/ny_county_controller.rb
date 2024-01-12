require 'csv'

module StateFile
  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      private

      def next_path
        options = { us_state: params[:us_state], action: :edit }
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NySchoolDistrictController.to_path_helper(options)
      end
    end
  end
end
