module StateFile
  module Questions
    class EligibilityOffboardingController < QuestionsController
      before_action :set_prev_path, only: [:edit]
      helper_method :ineligible_reason
      include VitaTransferConcern

      def edit
        product_type = FaqCategory.state_to_product_type(params[:us_state])
        @learn_more_link = FaqCategory.where(slug: "other_state_filing_options", product_type: product_type).present? ? state_faq_section_path(section_key: "other_state_filing_options") : state_faq_path
        @vita_link = vita_link
        super
      end

      def ineligible_reason
        key = current_intake.disqualifying_eligibility_answer
        if key.present?
          I18n.t(
            "state_file.questions.eligibility_offboarding.edit.ineligible_reason.#{key}",
            state: States.name_for_key(params[:us_state].upcase)
          )
        end
      end

      def set_prev_path
        @prev_path = session.delete(:offboarded_from)
      end

      def prev_path
        @prev_path || super
      end

      def self.show?(intake)
        intake.has_disqualifying_eligibility_answer?
      end
    end
  end
end