module StateFile
  module Questions
    class DataTransferOffboardingController < QuestionsController
      helper_method :ineligible_reason

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
    end
  end
end
