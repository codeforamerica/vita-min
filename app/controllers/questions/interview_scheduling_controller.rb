module Questions
  class InterviewSchedulingController < QuestionsController
    layout "question"

    def section_title
      "Additional Questions"
    end

    def illustration_path; end
  end
end