module Questions
  class InterviewSchedulingController < QuestionsController
    layout "intake"

    def edit
      super
    end

    def tracking_data
      {}
    end

    def illustration_path
      "phone-number.svg"
    end
  end
end
