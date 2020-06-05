module Zendesk
  class IntakesController < ApplicationController
    include ZendeskAuthenticationControllerHelper
    include FileResponseControllerHelper

    before_action :require_zendesk_user, :set_intake, :require_ticket_access
    helper_method :zendesk_ticket_id

    layout "admin"

    def intake_pdf
      render_pdf @intake.pdf
    end

    def consent_pdf
      render_pdf @intake.consent_pdf
    end

    def banking_info
    end

    private

    def set_intake
      @intake = Intake
        .where(zendesk_instance_domain: EitcZendeskInstance::DOMAIN)
        .find(params[:id])
    end

    def zendesk_ticket_id
      @intake.intake_ticket_id
    end
  end
end
