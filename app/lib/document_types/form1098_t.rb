module DocumentTypes
  class Form1098T < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_post_secondary_educational_expenses_yes?
      end

      def key
        "1098-T"
      end
    end
  end
end
