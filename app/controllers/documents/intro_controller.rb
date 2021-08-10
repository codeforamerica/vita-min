module Documents
  class IntroController < DocumentUploadQuestionController
    layout "intake"

    def edit
      data = MixpanelService.data_from([current_intake.client, current_intake])

      MixpanelService.send_event(
        distinct_id: current_intake.visitor_id,
        event_name: "intake_ids_uploaded",
        data: data
      )
    end

    def self.document_type
      nil
    end

    def illustration_path
      "documents.svg"
    end
  end
end
