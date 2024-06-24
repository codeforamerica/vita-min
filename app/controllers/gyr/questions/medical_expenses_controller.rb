module Questions
  class MedicalExpensesController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.wants_to_itemize_yes? || intake.wants_to_itemize_unsure?
    end

    private

    def method_name
      "paid_medical_expenses"
    end
  end
end
