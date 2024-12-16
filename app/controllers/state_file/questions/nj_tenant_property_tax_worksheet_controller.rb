module StateFile
  module Questions
    class NjTenantPropertyTaxWorksheetController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        StateFile::NjPropertyTaxFlowHelper.next_controller(options)
      end
    end
  end
end