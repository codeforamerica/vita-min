module DocumentTypes
  class Form1095A < DocumentType
    class << self
      def relevant_to?(intake)
        intake.bought_marketplace_health_insurance_yes?
      end

      def key
        "1095-A"
      end

      def needed_if_relevant?
        true
      end

      def provide_doc_help?
        true
      end
    end
  end
end
