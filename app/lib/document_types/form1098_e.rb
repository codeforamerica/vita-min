module DocumentTypes
  class Form1098E < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_student_loan_interest_yes?
      end

      def key
        "1098-E"
      end
    end
  end
end
