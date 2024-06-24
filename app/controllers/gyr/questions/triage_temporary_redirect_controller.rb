module Questions
  class TriageTemporaryRedirectController < QuestionsController
    before_action :redirect_to_first_triage_page
    before_action :require_intake

    def self.show?(_)
      false
    end

    def redirect_to_first_triage_page
      redirect_to Questions::TriageIncomeLevelController.to_path_helper
    end
  end
end
