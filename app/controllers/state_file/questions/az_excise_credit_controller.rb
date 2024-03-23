module StateFile
  module Questions
    class AzExciseCreditController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        !intake.disqualified_from_excise_credit_df?
      end

      def update
        if params["state_file_az_excise_credit_form"]["was_incarcerated"].present?
          flash[:notice] = I18n.t("state_file.questions.az_excise_credit.update.page_changed_notice")
          render :edit
        else
          super
        end
      end
    end
  end
end
