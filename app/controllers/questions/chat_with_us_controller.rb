module Questions
  class ChatWithUsController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    def edit
      @zip_name = ZipCodes.details(current_intake.zip_code)&.fetch(:name)
      @returning_client = current_intake.client.routing_method_returning_client?
    end

    private

    def illustration_path
      "chat-with-us.svg"
    end

    def self.form_class
      NullForm
    end
  end
end
