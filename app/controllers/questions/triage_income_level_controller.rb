module Questions
  class TriageIncomeLevelController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def next_path
      TriageResultService.new(current_intake).after_income_levels || super
    end

    private

    def illustration_path
      "balance-payment.svg"
    end
  end
end
