module DocumentTypes
  class Form1099A < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_debt_forgiven_yes?
      end

      def key
        "1099-A"
      end
    end
  end
end
