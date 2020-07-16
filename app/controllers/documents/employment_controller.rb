module Documents
  class EmploymentController < DocumentUploadQuestionController
    class << self
      def show?(intake)
        intake.had_wages_yes? ||
        intake.had_a_job? ||
        intake.had_disability_income_yes? ||
        intake.had_self_employment_income_yes?
      end

      def document_type
        "Employment"
      end

      def displayed_document_types
        %w[W-2 1099-K 1099-MISC Employment]
      end

    end
  end
end
