module Questions
  class FileWithHelpController < QuestionsController
    layout "question"

    private

    def illustration_path
      "file-with-help.svg"
    end

    def self.form_class
      NullForm
    end

  end
end
