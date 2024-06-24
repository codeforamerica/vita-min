module Questions
  class EnvironmentWarningController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    layout "intake"

    def self.show?(_)
      !Rails.env.production?
    end

    def self.form_class
      NullForm
    end
  end
end