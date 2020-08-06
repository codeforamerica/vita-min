module Zendesk
  class TicketsController < ApplicationController
    include ZendeskAuthenticationControllerHelper

    before_action :require_zendesk_user, :require_ticket_access
    helper_method :drop_off_upload_date

    layout "admin"

    def show
      @ticket = current_ticket
      @intakes = Intake.where(
        intake_ticket_id: zendesk_ticket_id,
        zendesk_instance_domain: EitcZendeskInstance::DOMAIN
      )
      @document_groups = DocumentPresenter.grouped_documents(@intakes)

      @drop_offs = IntakeSiteDropOff.where(zendesk_ticket_id: zendesk_ticket_id)
    end

    private

    def drop_off_upload_date(drop_off)
      "#{ActionController::Base.helpers.time_ago_in_words(drop_off.created_at)} ago"
    end

    def zendesk_ticket_id
      params[:id]
    end
  end
end
