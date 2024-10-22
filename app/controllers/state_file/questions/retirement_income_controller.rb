module StateFile
  module Questions
    class RetirementIncomeController < QuestionsController
      include ReturnToReviewConcern
      def review_step
        "StateFile::Questions::IncomeReviewController".constantize
      end
      def edit
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
      end

      def update
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
        @state_file1099_r.assign_attributes(state_file1099_r_params)

        if @state_file1099_r.valid?(:retirement_income_intake)
          @state_file1099_r.save(context: :retirement_income_intake)
          redirect_to edit_income_review_path, return_to_review: params[:return_to_review]
        else
          render :edit, return_to_review: params[:return_to_review]
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
    end
  end
end
