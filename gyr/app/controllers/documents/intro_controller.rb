module Documents
  class IntroController < DocumentUploadQuestionController
    layout "intake"

    def self.show?(intake)
      intake.document_types_definitely_needed.any?
    end

    def edit
      redirect_to Documents::OverviewController.to_path_helper unless self.class.show?(current_intake)

      if ReturningClientExperimentService.new(current_intake).skip_identity_documents?
        current_intake.tax_returns.each do |tax_return|
          tax_return.advance_to(:intake_ready) if tax_return.current_state.to_sym != :intake_ready
        end
      end
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
