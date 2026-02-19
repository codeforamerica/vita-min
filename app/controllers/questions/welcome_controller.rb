module Questions
  class WelcomeController < QuestionsController
    include AnonymousIntakeConcern

    before_action :redirect_to_eligibility_wages
    skip_before_action :require_intake
    layout "application"

    def redirect_to_eligibility_wages
      redirect_to eligibility_wages_questions_path
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