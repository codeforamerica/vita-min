module Questions
  class FilingForStimulusController < QuestionsController
    layout "yes_no_question"

    def show_progress?
      false
    end
  end
end
