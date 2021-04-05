module Portal
  class ClientLoginsController < ApplicationController
    before_action :redirect_to_portal_if_client_authenticated
    before_action :validate_token, only: [:edit, :update]
    before_action :redirect_locked_clients, only: [:edit, :update]
    layout "portal"

    def new
      @form = RequestClientLoginForm.new
    end

    def create
      @form = RequestClientLoginForm.new(request_client_login_params)
      if @form.valid?
        if @form.email_address.present?
          ClientEmailLoginRequestJob.perform_later(
            email_address: @form.email_address,
            locale: I18n.locale,
            visitor_id: visitor_id
          )
        end

        if @form.sms_phone_number.present?
          ClientTextMessageLoginRequestJob.perform_later(
            sms_phone_number: @form.sms_phone_number,
            locale: I18n.locale,
            visitor_id: visitor_id
          )
        end

        @verification_code_form = Portal::VerificationCodeForm.new(contact_info: @form.email_address.present? ? @form.email_address : @form.sms_phone_number)
        render :enter_verification_code
      else
        render :new
      end
    end

    def check_verification_code
      params = check_verification_code_params
      if params[:contact_info].blank?
        head :bad_request
        return
      end

      @verification_code_form = Portal::VerificationCodeForm.new(contact_info: params[:contact_info], verification_code: params[:verification_code])
      if @verification_code_form.valid?
        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(params[:contact_info], params[:verification_code])

        if ClientLoginsService.clients_for_token(hashed_verification_code).exists?
          DatadogApi.increment("client_logins.verification_codes.right_code")
          redirect_to edit_portal_client_login_path(id: hashed_verification_code)
          return
        else
          @verification_code_form.errors.add(:verification_code, I18n.t("portal.client_logins.form.errors.bad_verification_code"))
          DatadogApi.increment("client_logins.verification_codes.wrong_code")

          @clients = Client.by_contact_info(email_address: params[:contact_info], phone_number: params[:contact_info])
          @clients.map(&:increment_failed_attempts)
          return if redirect_locked_clients
        end
      end

      render :enter_verification_code
    end

    def account_locked; end

    def edit
      @form = ClientLoginForm.new(possible_clients: @clients)
    end

    def update
      @form = ClientLoginForm.new(client_login_params)
      if @form.valid?
        sign_in @form.client
        redirect_to session.delete(:after_client_login_path) || portal_root_path
      else
        @clients.each(&:increment_failed_attempts)

        # Re-checking if account is locked after incrementing
        return if redirect_locked_clients

        render :edit
      end
    end

    private

    def request_client_login_params
      params.require(:portal_request_client_login_form).permit(:email_address, :sms_phone_number)
    end

    def client_login_params
      params.require(:portal_client_login_form).permit(:last_four_or_client_id).merge(possible_clients: @clients)
    end

    def check_verification_code_params
      params.require(:portal_verification_code_form).permit(:contact_info, :verification_code)
    end

    def validate_token
      @clients = ClientLoginsService.clients_for_token(params[:id])
      redirect_to portal_client_logins_path unless @clients.present?
    end

    def redirect_locked_clients
      redirect_to account_locked_portal_client_logins_path if @clients.map(&:access_locked?).any?
    end

    def redirect_to_portal_if_client_authenticated
      redirect_to portal_root_path if current_client.present?
    end
  end
end
