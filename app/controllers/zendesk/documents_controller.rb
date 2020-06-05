module Zendesk
  class DocumentsController < ApplicationController
    include ZendeskAuthenticationControllerHelper
    include FileResponseControllerHelper

    before_action :require_zendesk_user, :set_document, :require_ticket_access

    def show
      render_active_storage_attachment @document.upload
    end

    private

    def set_document
      @document = Document.find(params[:id])
    end

    def zendesk_ticket_id
      return unless @document.intake.zendesk_instance_domain == EitcZendeskInstance::DOMAIN

      @document.intake.intake_ticket_id
    end
  end
end