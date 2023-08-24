module Questions
  class AssetSaleIncomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.sold_assets_yes?
    end

    private

    def method_name
      "had_asset_sale_income"
    end
  end
end