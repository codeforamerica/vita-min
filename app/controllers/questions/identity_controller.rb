module Questions
  class IdentityController < QuestionsController
    skip_before_action :require_intake
    layout "application"

    def self.form_class
      NullForm
    end

    def edit; end
  end
end
