module Questions
  class ChatWithUsController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    def edit
      ExperimentService.find_or_assign_treatment(
        key: ExperimentService::ID_VERIFICATION_EXPERIMENT,
        record: current_intake
      )
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
