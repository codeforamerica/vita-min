module Questions
  class AnonymousIntakeController < QuestionsController
    before_action :require_intake
  end
end
