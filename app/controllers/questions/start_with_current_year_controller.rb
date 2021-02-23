module Questions
  class StartWithCurrentYearController < QuestionsController
    layout "intake"

    private

    def self.form_class
      NullForm
    end
  end
end
