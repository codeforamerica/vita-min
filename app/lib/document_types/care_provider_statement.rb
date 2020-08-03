module DocumentTypes
  class CareProviderStatement < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_dependent_care_yes?
      end

      def key
        "Care Provider Statement"
      end
    end
  end
end
