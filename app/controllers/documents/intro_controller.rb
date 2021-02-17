module Documents
  class IntroController < DocumentUploadQuestionController
    layout "question"

    def illustration_path;end

    def edit
      data = MixpanelService.data_from([current_intake.client, current_intake])

      MixpanelService.send_event(
        event_id: current_intake.visitor_id,
        event_name: "intake_ids_uploaded",
        data: data
      )
    end

    def self.document_type
      nil
    end
  end
end
