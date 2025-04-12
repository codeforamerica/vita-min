module StateFile
  module Questions
    class RetirementIncomeController < QuestionsController
      before_action :load_1099_r
      before_action :load_warnings, only: [:edit]

      def prev_path
        StateFile::Questions::IncomeReviewController.to_path_helper(navigation_params)
      end

      def update
        @state_file1099_r.assign_attributes(state_file1099_r_params)

        if @state_file1099_r.valid?(:retirement_income_intake)
          @state_file1099_r.save(context: :retirement_income_intake)
          redirect_to questions_income_review_path(navigation_params)
        else
          render :edit
        end
      end

      private

      def load_1099_r
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
      end

      def load_warnings
        if @state_file1099_r.state_tax_withheld_amount == 0 || @state_file1099_r.state_tax_withheld_amount.nil?
          @state_file1099_r.errors.add(:state_tax_withheld_amount, I18n.t("state_file.questions.retirement_income.edit.state_tax_withheld_absent_warning"))
        end
        if @state_file1099_r.state_tax_withheld_amount.present? && @state_file1099_r.state_tax_withheld_amount > @state_file1099_r.gross_distribution_amount
          @state_file1099_r.errors.add(:state_tax_withheld_amount, I18n.t("activerecord.errors.models.state_file1099_r.errors.must_be_less_than_gross_distribution", gross_distribution_amount: @state_file1099_r.gross_distribution_amount))
        end
      end

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
