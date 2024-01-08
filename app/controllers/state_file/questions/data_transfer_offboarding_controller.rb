module StateFile
  module Questions
    class DataTransferOffboardingController < StateFile::Questions::QuestionsController
      helper_method :ineligible_reason

      def edit
        super
        product_type = params[:us_state] == 'az' ? "state_file_az" : "state_file_ny"
        @learn_more_link = FaqCategory.where(slug: "other_state_filing_options", product_type: product_type).present? ? state_faq_section_path(section_key: "other_state_filing_options") : state_faq_path
      end

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
