module Questions
  class OverviewDocumentsController < QuestionsController
    skip_before_action :require_sign_in
    before_action :require_intake
    layout "application"

    def self.form_class
      NullForm
    end
  end
end
