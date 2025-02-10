module StateFile
  module Questions
    class IdDisabilityController < QuestionsController
      def self.show?(intake)
        current_intake.state_file1099_rs.any? { |form1099r| form1099r.taxable_amount&.to_f&.positive? } &&
          current_intake.primary_senior? && !current_intake.filing_status_mfs?
      end
    end
  end
end
