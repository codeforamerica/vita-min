module DocumentTypes
  class Form1099G < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_unemployment_income_yes?
      end

      def key
        "1099-G"
      end
    end
  end
end
