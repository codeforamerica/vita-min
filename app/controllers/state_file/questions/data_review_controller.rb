module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
        super
        # Redirect to offboarding here if not eligible
        if current_intake&.has_disqualifying_eligibility_answer? ||
           current_intake&.disqualifying_df_data_reason.present?
          redirect_to next_path and return
        end
        if current_intake&.df_data_import_succeeded_at.nil?
          redirect_to StateFilePagesController.to_path_helper(action: :data_import_failed) and return
        end

        redirect_to next_path
      end

      private

      def prev_path
        nil
      end
    end
  end
end
