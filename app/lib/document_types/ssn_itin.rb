module DocumentTypes
  class SsnItin < DocumentType
    class << self
      def relevant_to?(_intake)
        true
      end

      def key
        "SSN or ITIN"
      end

      def needed_if_relevant?
        true
      end

      def blocks_progress?
        true
      end

      def provide_doc_help?
        true
      end

      def needed_for_spouse
        true
      end

      def needed_for_dependents
        true
      end
    end
  end
end
