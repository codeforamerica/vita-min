module Ctc
  module Questions
    class RemoveSpouseController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def edit
        redirect_to next_path unless current_intake.spouse.full_name.present?

        super
      end

      def self.show?(intake)
        intake.filing_jointly?
      end

      private

      def next_path
        questions_filing_status_path
      end

      def prev_path
        questions_spouse_info_path
      end

      def illustration_path; end

    end
  end
end
