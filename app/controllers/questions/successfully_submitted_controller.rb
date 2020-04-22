module Questions
  class SuccessfullySubmittedController < QuestionsController
    append_after_action :reset_session, :track_page_view

    def edit
    end
  end
end
