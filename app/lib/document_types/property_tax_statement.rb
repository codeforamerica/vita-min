module DocumentTypes
  class PropertyTaxStatement < DocumentType
    class << self
      def relevant_to?(intake)
        intake.paid_local_tax_yes?
      end

      def key
        "Property Tax Statement"
      end
    end
  end
end
