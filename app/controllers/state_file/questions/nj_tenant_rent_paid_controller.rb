module StateFile
  module Questions
    class NjTenantRentPaidController < QuestionsController

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
      end

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjHouseholdRentOwnController.to_path_helper(options)
      end
    end
  end
end
