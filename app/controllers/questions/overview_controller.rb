module Questions
  class OverviewController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    def illustration_path; end

    def self.form_class
      NullForm
    end
  end
end


