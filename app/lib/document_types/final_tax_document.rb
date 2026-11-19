module DocumentTypes
  class FinalTaxDocument < DocumentType
    class << self
      def key
        "Final Tax Document"
      end

      def blocks_progress?
        false
      end

      def must_be_associated_with_tax_return
        true
      end
    end
  end
end
