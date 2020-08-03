module DocumentTypes
  class Form1098T < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_student_in_family_yes?
      end

      def key
        "1098-T"
      end
    end
  end
end
