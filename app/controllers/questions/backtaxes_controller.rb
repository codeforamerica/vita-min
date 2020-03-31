module Questions
  class BacktaxesController < QuestionsController
    skip_before_action :require_sign_in
    before_action :require_intake
    layout "question"
  end
end
