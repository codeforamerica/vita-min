module StateFile
  module Questions
    class DataTransferOffboardingController < AuthenticatedQuestionsController
      include OtherOptionsLinksConcern
      helper_method :ineligible_reason

      def ineligible_reason
        key = current_intake.disqualifying_df_data_reason
        if key.present?
          I18n.t(
            "state_file.questions.data_transfer_offboarding.edit.ineligible_reason.#{key}",
            state: current_state_name
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
