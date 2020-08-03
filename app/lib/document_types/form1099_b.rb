module DocumentTypes
  class Form1099B < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_asset_sale_income_yes?
      end

      def key
        "1099-B"
      end
    end
  end
end
