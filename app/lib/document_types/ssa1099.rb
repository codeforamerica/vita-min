module DocumentTypes
  class Ssa1099 < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_social_security_income_yes?
      end

      def key
        "SSA-1099"
      end

      def description
        "It should say SSA-1099 and Social Security Benefit Statement on the top of the document"
      end

      def provide_doc_help?
        true
      end
    end
  end
end
