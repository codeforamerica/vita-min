module DocumentTypes
  class Employment < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_wages_yes? ||
            intake.had_a_job? ||
            intake.had_disability_income_yes? ||
            intake.had_self_employment_income_yes?
      end

      def key
        "Employment"
      end
    end
  end
end
