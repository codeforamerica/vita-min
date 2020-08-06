module Zendesk
  class DropOffsController < ApplicationController
    include ZendeskAuthenticationControllerHelper
    include FileResponseControllerHelper

    before_action :require_zendesk_user, :set_drop_off, :require_ticket_access

    def show
      render_active_storage_attachment @drop_off.document_bundle
    end

    private

    def set_drop_off
      @drop_off = IntakeSiteDropOff.find(params[:id])
    end

    def zendesk_ticket_id
      @drop_off.zendesk_ticket_id
    end
  end
end