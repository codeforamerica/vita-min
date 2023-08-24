module Questions
  class StartWithCurrentYearController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    private

    def self.form_class
      NullForm
    end
  end
end
