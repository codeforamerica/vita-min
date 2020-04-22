module Questions
  class StartWithCurrentYearController < QuestionsController
    layout "question"

    private

    def illustration_path
      "backtaxes.svg"
    end

    def self.form_class
      NullForm
    end
  end
end
