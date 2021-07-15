module Questions
  class FileWithHelpController < QuestionsController
    include AnonymousIntakeConcern
    include PreviousPathIsBackConcern
    skip_before_action :require_intake
    layout "intake"

    def next_path
      backtaxes_questions_path
    end

    private

    def self.form_class
      NullForm
    end

    def show_progress?
      false
    end
  end
end
