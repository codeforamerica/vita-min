module Questions
  class AnonymousIntakeController < QuestionsController
    before_action :require_intake, :set_show_client_sign_in_link

    private

    def set_show_client_sign_in_link
      @show_client_sign_in_link = true
    end
  end
end
