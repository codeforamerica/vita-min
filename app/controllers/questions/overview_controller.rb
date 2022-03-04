module Questions
  class OverviewController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    layout "intake"

    def illustration_path; end

    def self.form_class
      NullForm
    end
  end
end


