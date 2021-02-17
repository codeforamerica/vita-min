module Questions
  class ChatWithUsController < QuestionsController
    layout "intake"

    def edit
      @zip_name = ZipCodes.details(current_intake.zip_code)&.fetch(:name)
    end

    private

    def illustration_path
      current_intake.vita_partner&.logo_path
    end

    def self.form_class
      NullForm
    end
  end
end
