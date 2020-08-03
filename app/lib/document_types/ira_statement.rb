module DocumentTypes
  class IraStatement < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_retirement_contributions_yes?
      end

      def key
        "IRA Statement"
      end
    end
  end
end
