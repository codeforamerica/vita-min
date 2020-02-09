module Questions
  class LinkSentController < QuestionsController
    def self.form_class
      NullForm
    end
  end
end