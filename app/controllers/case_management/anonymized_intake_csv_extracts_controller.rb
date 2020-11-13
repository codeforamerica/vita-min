module CaseManagement
  class AnonymizedIntakeCsvExtractsController < ApplicationController
    # before_action :require_admin

    layout "admin"

    def index
      @extracts = AnonymizedIntakeCsvExtract.order(run_at: :desc).all
    end

    def show
      extract = AnonymizedIntakeCsvExtract.find(params[:id])
      if extract
        attachment = extract.upload
        send_data(attachment.download, filename: attachment.filename.to_s, type: attachment.content_type, disposition: "attachment")
      end
    end
  end
end
