module Questions
  class ChatWithUsController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    def edit
      if current_intake.matching_previous_year_intake.present?
        ExperimentService.find_or_assign_treatment(
          key: ExperimentService::RETURNING_CLIENT_EXPERIMENT,
          record: current_intake,
          vita_partner_id: current_intake.vita_partner.id
        )
      end

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
