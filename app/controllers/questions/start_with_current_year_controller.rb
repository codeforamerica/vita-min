module Questions
  class StartWithCurrentYearController < QuestionsController
    skip_before_action :require_sign_in
    before_action :require_intake

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