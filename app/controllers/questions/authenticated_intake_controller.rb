module Questions
  class AuthenticatedIntakeController < QuestionsController
    include ClientAccessControlConcern

    before_action :require_client_login

    def current_intake
      current_client&.intake
    end
  end
end
