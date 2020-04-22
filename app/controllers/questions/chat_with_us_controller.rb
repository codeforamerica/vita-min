module Questions
  class ChatWithUsController < QuestionsController
    layout "question"

    private

    def self.form_class
      NullForm
    end
  end
end
