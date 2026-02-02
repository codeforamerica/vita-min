module DocumentTypes
  class Employment < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_earned_income? || intake.had_disability_income_yes?
      end

      def description
        "Employment and income documents including: W-2 forms, 1099-K, 1099-NEC, 1099-MISC, paystubs,
          or any documentation showing income earned (can be formal tax documents or informal records
          like handwritten notes stating income amounts and dates, e.g. 'In May I made $33,000 in cash')."
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
