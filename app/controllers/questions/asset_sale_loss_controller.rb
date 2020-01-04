module Questions
  class AssetSaleLossController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      !intake.had_asset_sale_income_no?
    end
  end
end