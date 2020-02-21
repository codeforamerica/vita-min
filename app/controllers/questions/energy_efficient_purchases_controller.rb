module Questions
  class EnergyEfficientPurchasesController < QuestionsController
    layout "yes_no_question"

    def illustration_path; end

    def section_title
      "Income and Expenses"
    end
  end
end