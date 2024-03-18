module StateFile
  module Questions
    class EligibleController < QuestionsController
      include OtherOptionsLinksConcern

      def edit
        super
        @vita_link = vita_link
        @faq_other_options_link = faq_state_filing_options_link
      end

      private

      def form_class
        NullForm
      end
    end
  end
end