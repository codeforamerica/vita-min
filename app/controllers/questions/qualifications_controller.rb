module Questions
  class QualificationsController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    layout "intake"

    def prev_path
      triage_gyr_questions_path
    end
    def self.form_class
      NullForm
    end

    def illustration_path; end
  end
end
