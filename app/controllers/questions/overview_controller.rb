module Questions
  class OverviewController < QuestionsController
    layout "application"

    def self.form_class
      NullForm
    end
  end
end
