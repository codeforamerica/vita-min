module Questions
  class HsaController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "had_hsa"
    end
  end
end
