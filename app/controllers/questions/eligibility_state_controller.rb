module Questions
  class EligibilityStateController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"
  end
end
