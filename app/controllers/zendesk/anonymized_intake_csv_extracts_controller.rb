module Zendesk
  class AnonymizedIntakeCsvExtractsController < ApplicationController
    include ZendeskAuthenticationControllerHelper

    #TODO: Make sure that user has admin role
    before_action :require_zendesk_user

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
