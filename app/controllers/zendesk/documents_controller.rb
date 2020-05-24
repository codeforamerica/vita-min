module Zendesk
  class DocumentsController < ApplicationController
    before_action :require_zendesk_user, :set_document

    def show
      return render "public_pages/page_not_found", status: 404 unless current_ticket.present?

      response.headers["Content-Type"] = @document.upload.content_type
      response.headers["Content-Disposition"] = "inline"

      @document.upload.download do |chunk|
        response.stream.write(chunk)
      end
    end

    private

    def require_zendesk_user
      unless current_user&.provider == "zendesk"
        session[:after_login_path] = request.path
        redirect_to zendesk_sign_in_path
      end
    end

    def set_document
      @document = Document.find(params[:id])
    end

    def current_ticket
      ticket_id = @document.intake.intake_ticket_id
      return unless ticket_id.present?

      zendesk_client.tickets.find(id: ticket_id)
    end

    def zendesk_client
      @zendesk_client ||= ZendeskAPI::Client.new do |config|
        config.access_token = current_user.access_token
        config.url = "https://eitc.zendesk.com/api/v2"
      end
    end
  end
end