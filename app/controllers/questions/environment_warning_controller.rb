module Questions
  class EnvironmentWarningController < QuestionsController
    layout "question"

    def self.show?(_)
      !Rails.env.production?
    end

    def self.form_class
      NullForm
    end
  end
end