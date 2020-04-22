module Questions
  class OverviewDocumentsController < QuestionsController
    before_action :require_intake
    layout "application"

    def self.form_class
      NullForm
    end
  end
end
