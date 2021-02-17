module Questions
  class EnvironmentWarningController < QuestionsController
    layout "intake"

    def self.show?(_)
      !Rails.env.production?
    end

    def self.form_class
      NullForm
    end
  end
end