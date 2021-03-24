module Questions
  class AssetSaleLossController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.sold_assets_yes?
    end

    private

    def method_name
      "reported_asset_sale_loss"
    end
  end
end