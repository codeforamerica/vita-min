require 'csv'

module StateFile

  module Questions
    class NjCountyController < QuestionsController
      include ReturnToReviewConcern

      private

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjMunicipalityController.to_path_helper(options)
      end
    end
  end
end
