module DocumentTypes
  class Form1099Div < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_interest_income_yes?
      end

      def key
        "1099-DIV"
      end

      def provide_doc_help?
        true
      end
    end
  end
end
