module Questions
  class IrsLetterController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Life Events"
    end

    def no_illustration?
      true
    end
  end
end