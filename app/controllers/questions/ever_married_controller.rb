module Questions
  class EverMarriedController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "married.svg"
    end

    def method_name
      "ever_married"
    end
  end
end
