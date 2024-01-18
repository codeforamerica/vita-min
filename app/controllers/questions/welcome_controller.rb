module Questions
  class WelcomeController < QuestionsController
    include AnonymousIntakeConcern

    before_action :redirect_to_triage_personal_info
    skip_before_action :require_intake
    layout "application"

    def redirect_to_triage_personal_info
      redirect_to triage_personal_info_questions_path
      # fake change 1
    end

    def self.show?(_intake, _current_controller)
      false
    end

    def self.deprecated_controller?
      true
    end

    private

    def illustration_path; end
  end
end