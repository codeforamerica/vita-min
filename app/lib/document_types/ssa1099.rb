module DocumentTypes
  class Ssa1099 < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_social_security_income_yes?
      end

      def key
        "SSA-1099"
      end

      def provide_doc_help?
        true
      end
    end
  end
end
