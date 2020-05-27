module Zendesk
  class TicketsController < ApplicationController
    include ZendeskAuthenticationControllerHelper

    before_action :require_zendesk_user, :require_ticket_access

    def show
      @ticket = current_ticket
      @intakes = Intake.where(intake_ticket_id: zendesk_ticket_id)
      @documents = Document.where(intake: @intakes)
    end

    private

    def zendesk_ticket_id
      params[:id]
    end
  end
end