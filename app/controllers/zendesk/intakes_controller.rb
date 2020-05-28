module Zendesk
  class IntakesController < ApplicationController
    include ZendeskAuthenticationControllerHelper
    include FileResponseControllerHelper

    before_action :require_zendesk_user, :set_intake, :require_ticket_access

    def intake_pdf
      render_pdf @intake.pdf
    end

    def consent_pdf
      render_pdf @intake.consent_pdf
    end

    private

    def set_intake
      @intake = Intake.find(params[:id])
    end

    def zendesk_ticket_id
      @intake.intake_ticket_id
    end
  end
end