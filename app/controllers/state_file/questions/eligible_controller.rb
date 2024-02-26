module StateFile
  module Questions
    class EligibleController < QuestionsController
      include OtherOptionsLinksConcern

      def edit
        super
        @faq_other_options_link = faq_state_filing_options_link
        @state_name = States.name_for_key(params[:us_state].upcase)
      end

      private

      def form_class
        NullForm
      end
    end
  end
end