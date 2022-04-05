module Questions
  class PostCompletionQuestionsController < QuestionsController
    skip_before_action :redirect_if_completed_intake_present
  end
end
