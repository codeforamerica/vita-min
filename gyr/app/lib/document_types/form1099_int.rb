module DocumentTypes
  class Form1099Int < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_interest_income_yes?
      end

      def key
        "1099-INT"
      end
    end
  end
end
