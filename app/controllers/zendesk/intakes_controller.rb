module Zendesk
  class IntakesController < ApplicationController
    before_action :require_zendesk_user, :set_intake, :require_ticket_access

    def intake_pdf
      send_pdf(@intake.pdf)
    end

    def consent_pdf
      send_pdf(@intake.consent_pdf)
    end

    private

    def send_pdf(pdf_file)
      send_data(pdf_file.read, type: "application/pdf", disposition: "inline")
    end

    def set_intake
      @intake = Intake.find(params[:id])
    end

    def require_zendesk_user
      unless current_user&.provider == "zendesk"
        session[:after_login_path] = request.path
        redirect_to zendesk_sign_in_path
      end
    end

    def current_ticket
      ticket_id = @intake.intake_ticket_id
      return unless ticket_id.present?

      @ticket ||= zendesk_client.tickets.find(id: ticket_id)
    end

    def zendesk_client
      @zendesk_client ||= ZendeskAPI::Client.new do |config|
        config.access_token = current_user.access_token
        config.url = "https://eitc.zendesk.com/api/v2"
      end
    end

    def require_ticket_access
      return render "public_pages/page_not_found", status: 404 unless current_ticket.present?
    end
  end
end