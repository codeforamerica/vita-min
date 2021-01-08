module DocumentTypes
  class FinalTaxDocument < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        false
      end

      def key
        "Final Tax Document"
      end

      def blocks_progress?
        false
      end
    end
  end
end
