module Questions
  class ChatWithUsController < QuestionsController
    skip_before_action :require_sign_in
    layout "question"

    private

    def self.form_class
      NullForm
    end
  end
end
