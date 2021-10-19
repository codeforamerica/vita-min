module Questions
  class EnergyEfficientPurchasesController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "bought_energy_efficient_items"
    end

    def after_update_success
      current_intake.update(completed_yes_no_questions_at: DateTime.current) if current_intake.completed_yes_no_questions_at.nil?
      IntakePdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
