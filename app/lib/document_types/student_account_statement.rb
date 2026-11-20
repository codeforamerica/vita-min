module DocumentTypes
  class StudentAccountStatement < DocumentType
    class << self
      def relevant_to?(intake)
        intake.any_students?
      end

      def key
        "Student Account Statement"
      end
    end
  end
end
