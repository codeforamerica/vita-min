module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def section_title
      "Additional Questions"
    end
  end
end