module DocumentTypes
  class PriorYearTaxReturn < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_local_tax_refund_yes? || intake.reported_asset_sale_loss_yes?
      end

      def key
        "Prior Year Tax Return"
      end
    end
  end
end
