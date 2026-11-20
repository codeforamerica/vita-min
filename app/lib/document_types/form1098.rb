module DocumentTypes
  class Form1098 < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_mortgage_interest_yes? || intake.paid_local_tax_yes?
      end

      def key
        "1098"
      end
    end
  end
end
