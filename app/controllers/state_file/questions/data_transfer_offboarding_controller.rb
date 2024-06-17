module StateFile
  module Questions
    class DataTransferOffboardingController < StateFile::Questions::QuestionsController
      helper_method :ineligible_reason
      include OtherOptionsLinksConcern

      def edit
        super
        @learn_more_link = faq_state_filing_options_link
        @vita_link = vita_link
      end

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
