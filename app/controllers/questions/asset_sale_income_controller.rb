module Questions
  class AssetSaleIncomeController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.sold_assets_yes?
    end
  end
end