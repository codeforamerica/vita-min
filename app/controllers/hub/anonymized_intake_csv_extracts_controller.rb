module Hub
  class AnonymizedIntakeCsvExtractsController < ApplicationController
    include FilesConcern
    layout "hub"

    load_and_authorize_resource

    def index
      @extracts = @anonymized_intake_csv_extracts.order(run_at: :desc)
    end

    def show
      redirect_to transient_storage_url(@anonymized_intake_csv_extract.upload.blob, disposition: "attachment")
    end
  end
end
