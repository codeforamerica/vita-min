module Questions
  class SuccessfullySubmittedController < QuestionsController
    skip_before_action :require_intake
    append_after_action :reset_session, :track_page_view

    def edit
    end
  end
end
