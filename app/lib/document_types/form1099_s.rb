module DocumentTypes
  class Form1099S < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_asset_sale_income_yes? || intake.sold_a_home_yes?
      end

      def key
        "1099-S"
      end
    end
  end
end
