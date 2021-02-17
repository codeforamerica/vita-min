module Questions
  class OverviewController < QuestionsController
    layout "intake"

    def illustration_path; end

    def self.form_class
      NullForm
    end
  end
end
