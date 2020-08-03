module DocumentTypes
  class Form1099R < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_retirement_income_yes?
      end

      def key
        "1099-R"
      end

      def needed_if_relevant?
        true
      end
    end
  end
end
