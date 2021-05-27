module Questions
  class AuthenticatedIntakeController < QuestionsController
    include ClientAccessControlConcern

    before_action :require_client_login, :redirect_to_still_needs_help_if_necessary

    def current_intake
      current_client&.intake
    end
  end
end
