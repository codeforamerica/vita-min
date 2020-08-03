module DocumentTypes
  class Rrb1099 < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_social_security_income_yes?
      end

      def key
        "RRB-1099"
      end
    end
  end
end
