module DocumentTypes
  class UnsignedForm8879 < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        false
      end

      def key
        "Form 8879 (Unsigned)"
      end

      def blocks_progress?
        false
      end

      def must_be_associated_with_tax_return
        true
      end

      def writeable_locations
        {
          primary_signature: { y: 315, x: 90 },
          primary_signed_on: { y: 315, x: 400 },
          spouse_signature: { y: 195, x: 90 },
          spouse_signed_on: { y: 195, x: 400 },
          preparer_signature: { y: 75, x: 90 },
          preparer_signed_on: { y: 75, x: 400 }
        }
      end
    end
  end
end
