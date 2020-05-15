module Questions
  class FileWithHelpController < QuestionsController
    skip_before_action :require_intake
    layout "question"

    private

    def self.form_class
      NullForm
    end
  end
end
