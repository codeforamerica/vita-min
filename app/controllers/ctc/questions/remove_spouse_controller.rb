module Ctc
  module Questions
    class RemoveSpouseController < QuestionsController
      # include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def edit
        super
      end

      def self.show?(intake)
        intake.client.tax_returns.last.filing_status_married_filing_jointly? #move out into own function
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end

    end
  end
end