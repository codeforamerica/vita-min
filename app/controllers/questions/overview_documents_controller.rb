module Questions
  class OverviewDocumentsController < QuestionsController
    include AuthenticatedClientConcern

    before_action :require_intake
    layout "intake"

    def self.show?(intake)
      return false if intake.source == "211intake"

      super
    end

    def self.form_class
      NullForm
    end

    def next_path
      next_step = DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end
