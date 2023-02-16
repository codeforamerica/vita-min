module Questions
  class HsaController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(_intake)
      false
    end

    def edit
      redirect_to health_insurance_questions_path
    end

    def update
      redirect_to health_insurance_questions_path
    end

    private

    def method_name
      "had_hsa"
    end
  end
end
