module Portal
  class ClientLoginsController < ApplicationController
    before_action :redirect_to_portal_if_client_authenticated
    before_action :validate_token, only: [:show, :update]
    before_action :redirect_locked_clients, only: [:show, :update]
    layout "portal"

    def new
      @form = RequestClientLoginForm.new
    end

    def create
      @form = RequestClientLoginForm.new(request_client_login_params)
      if @form.valid?
        ClientEmailLoginRequestJob.perform_later(
          email_address: @form.email_address,
          locale: I18n.locale,
          visitor_id: visitor_id
        ) if @form.email_address.present?

        ClientTextMessageLoginRequestJob.perform_later(
          sms_phone_number: @form.sms_phone_number,
          locale: I18n.locale,
          visitor_id: visitor_id
        ) if @form.sms_phone_number.present?

        redirect_to login_link_sent_portal_client_logins_path
      else
        render :new
      end
    end

    def link_sent; end

    def invalid_token; end

    def account_locked; end

    def show
      @form = ClientLoginForm.new(possible_clients: @clients)
    end

    def update
      @form = ClientLoginForm.new(client_login_params)
      if @form.valid?
        sign_in @form.client
        redirect_to portal_root_path
      else
        @clients.each(&:increment_failed_attempts)

        # Re-checking if account is locked after incrementing
        return if redirect_locked_clients

        render :show
      end
    end

    private

    def request_client_login_params
      params.require(:portal_request_client_login_form).permit(:email_address, :sms_phone_number)
    end

    def client_login_params
      params.require(:portal_client_login_form).permit(:last_four, :confirmation_number).merge(possible_clients: @clients)
    end

    def validate_token
      @clients = ClientLoginsService.clients_for_token(params[:id])
      redirect_to invalid_token_portal_client_logins_path unless @clients.present?
    end

    def redirect_locked_clients
      redirect_to account_locked_portal_client_logins_path if @clients.map(&:access_locked?).any?
    end

    def redirect_to_portal_if_client_authenticated
      redirect_to portal_root_path if current_client.present?
    end
  end
end
