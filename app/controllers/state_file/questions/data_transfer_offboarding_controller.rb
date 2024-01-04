module StateFile
  module Questions
    class DataTransferOffboardingController < AuthenticatedQuestionsController
      helper_method :ineligible_reason
      skip_before_action :require_state_file_intake_login

      def ineligible_reason
        key = current_intake.disqualifying_df_data_reason
        if key.present?
          I18n.t(
            "state_file.questions.data_transfer_offboarding.edit.ineligible_reason.#{key}",
            state: States.name_for_key(params[:us_state].upcase)
          )
        end
      end

      def self.show?(intake)
        intake.disqualifying_df_data_reason.present?
      end

      private

      def card_postscript; end

    end
  end
end
