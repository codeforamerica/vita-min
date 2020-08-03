module DocumentTypes
  class Identity < DocumentType
    class << self
      def relevant_to?(_intake)
        true
      end

      def key
        "ID"
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
