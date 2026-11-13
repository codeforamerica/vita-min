module Questions
  class InterviewSchedulingController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def edit
      super
    end

    private

    def tracking_data
      {}
    end
  end
end
