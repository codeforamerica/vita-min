module Hub
  class AnonymizedIntakeCsvExtractsController < ApplicationController
    layout "admin"

    load_and_authorize_resource

    def index
      @extracts = @anonymized_intake_csv_extracts.order(run_at: :desc)
    end

    def show
      redirect_to rails_blob_path(@anonymized_intake_csv_extract.upload.blob, disposition: "attachment")
    end
  end
end
