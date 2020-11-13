module Questions
  class SoldAssetsController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end
  end
end