module StateFile
  module Questions
    class DataTransferOffboardingController < QuestionsController
      helper_method :ineligible_reason

      def ineligible_reason
        key = current_intake.disqualifying_df_data_field
        if key.present?
          I18n.t(
            "state_file.questions.data_transfer_offboarding.edit.ineligible_reason.#{key}",
            state: States.name_for_key(params[:us_state].upcase)
          )
        end
      end

      def self.show?(intake)
        intake.has_disqualifying_df_data_field?
      end
    end
  end
end
