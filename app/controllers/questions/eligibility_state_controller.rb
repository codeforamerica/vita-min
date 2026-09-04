module Questions
  class EligibilityStateController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def illustration_path; end
  end
end
