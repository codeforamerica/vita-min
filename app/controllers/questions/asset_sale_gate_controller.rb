module Questions
  class AssetSaleGateController < TicketedQuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end
  end
end