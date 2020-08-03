module DocumentTypes
  class Selfie < DocumentType
    class << self
      def relevant_to?(_intake)
        true
      end

      def key
        "Selfie"
      end

      def needed_if_relevant?
        true
      end

      def blocks_progress?
        true
      end
    end
  end
end
