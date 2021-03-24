module Questions
  class MedicalExpensesController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "paid_medical_expenses"
    end
  end
end
