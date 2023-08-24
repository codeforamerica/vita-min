module DocumentTypes
  class W2G < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_gambling_income_yes?
      end

      def key
        "W-2G"
      end
    end
  end
end
