module DocumentTypes
  class Form8879 < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        false
      end

      def key
        "Form 8879"
      end

      def blocks_progress?
        false
      end
    end
  end
end
