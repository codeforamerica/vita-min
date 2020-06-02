module Zendesk
  class TicketsController < ApplicationController
    include ZendeskAuthenticationControllerHelper

    before_action :require_zendesk_user, :require_ticket_access

    layout "admin"

    def show
      @ticket = current_ticket
      @intakes = Intake.where(intake_ticket_id: zendesk_ticket_id)
      @document_groups = DocumentPresenter.grouped_documents(@intakes)
    end

    private

    def zendesk_ticket_id
      params[:id]
    end
  end
end
