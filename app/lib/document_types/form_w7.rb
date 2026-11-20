module DocumentTypes
  class FormW7 < DocumentType
    class << self
      def relevant_to?(intake)
        false
      end

      def key
        "Form W-7"
      end

      def must_not_be_associated_with_tax_return
        true
      end

      def blocks_progress?
        false
      end
    end
  end
end
