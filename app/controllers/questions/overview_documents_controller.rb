module Questions
  class OverviewDocumentsController < QuestionsController
    before_action :require_intake
    layout "application"

    def self.form_class
      NullForm
    end

    def next_path
      next_step = DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end
