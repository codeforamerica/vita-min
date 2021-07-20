module Ctc
  module Questions
    class RemoveSpouseController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def edit
        redirect_to questions_filing_status_path unless current_intake.spouse_full_name.present?

        super
      end

      def self.show?(intake)
        intake.client.tax_returns.last.filing_status_married_filing_jointly? #move out into own function
      end

      def next_path
        questions_filing_status_path
      end

      def prev_path
        questions_spouse_info_path
      end

      private

      def illustration_path; end

    end
  end
end