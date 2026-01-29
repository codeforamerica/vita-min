module Questions
  class QualificationsController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    layout "intake"

    def self.form_class
      NullForm
    end

    def illustration_path; end
  end
end
