module Questions
  class AssetSaleLossController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Income"
    end
  end
end