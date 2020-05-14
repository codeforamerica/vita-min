module Questions
  class AlreadyFiledController < QuestionsController
    layout "yes_no_question"

    private

    def illustration_path
      "backtaxes.svg"
    end

  end
end
