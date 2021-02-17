module Questions
  class OverviewController < QuestionsController
    layout "question"

    def illustration_path;end

    def self.form_class
      NullForm
    end
  end
end
