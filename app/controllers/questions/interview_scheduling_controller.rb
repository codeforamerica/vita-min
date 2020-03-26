module Questions
  class InterviewSchedulingController < QuestionsController
    layout "question"

    def section_title
      "Additional Questions"
    end

    def tracking_data
      {}
    end
  end
end
