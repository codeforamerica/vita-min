module StateFile
  module Questions
    class IncomeReviewController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_sorted_vars

      def set_sorted_vars 
        @w2s = current_intake.state_file_w2s&.sort_by { |w2| [w2.employee_name, w2.employer_name] }
      end

      def update
        update_for_device_id_collection(current_intake&.initial_efile_device_info)
      end
    end
  end
end
