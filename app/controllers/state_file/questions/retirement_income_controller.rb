module StateFile
  module Questions
    class RetirementIncomeController < QuestionsController
      before_action :allows_1099_r_editing, only: [:edit, :update]

      def prev_path
        StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review])
      end

      def show
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
      end

      def edit
        form1099r = current_intake.state_file1099_rs.find(params[:id])
        form1099r.valid?(:income_review)
        @state_file1099_r = form1099r
      end

      def update
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
        @state_file1099_r.assign_attributes(state_file1099_r_params)

        if @state_file1099_r.valid?(:retirement_income_intake)
          @state_file1099_r.save(context: :retirement_income_intake)
          redirect_to questions_income_review_path(return_to_review: params[:return_to_review])
        else
          render :edit
        end
      end

      private

      def state_file1099_r_params
        params.require(:state_file1099_r).permit(
          :state_tax_withheld_amount,
          :payer_state_identification_number,
          :state_distribution_amount
        )
      end

      def allows_1099_r_editing
        unless current_intake.allows_1099_r_editing?
          redirect_to prev_path
        end
      end
    end
  end
end
