module Hub
  class AnonymizedIntakeCsvExtractsController < ApplicationController
    layout "admin"

    load_and_authorize_resource

    def index
      @extracts = @anonymized_intake_csv_extracts.order(run_at: :desc)
    end

    def show
      if @anonymized_intake_csv_extract
        attachment = @anonymized_intake_csv_extract.upload
        send_data(attachment.download, filename: attachment.filename.to_s, type: attachment.content_type, disposition: "attachment")
      end
    end
  end
end
