module DocumentTypes
  class Employment < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_earned_income? || intake.had_disability_income_yes?
      end

      def key
        "Employment"
      end

      def needed_if_relevant?
        true
      end

      def provide_doc_help?
        true
      end
    end
  end
end
