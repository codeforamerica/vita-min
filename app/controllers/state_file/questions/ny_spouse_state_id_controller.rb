module StateFile
  module Questions
    class NySpouseStateIdController < QuestionsController
      def self.show?(intake)
        intake.filing_status_mfj?
      end

      def edit
        @person_type = :spouse
        super
      end

      private

      def edit_template
        "state_file/questions/ny_state_id/edit"
      end
    end
  end
end
