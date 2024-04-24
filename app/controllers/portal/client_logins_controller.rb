module Portal
  class ClientLoginsController < ApplicationController
    before_action :gyr_redirect_unless_open_for_logged_in_clients
    before_action :redirect_to_portal_if_client_authenticated
    before_action :validate_token, only: [:edit, :update]
    before_action :redirect_locked_clients, only: [:edit, :update] # TODO: do this on check_verification_code and update instead? weird to have it on a get request; also it happens at the end of check_verification_code anyway
    layout "portal"

    def new
      # Displays the enter email / phone number
      @form = request_login_form_class.new
    end

    def create
      # Sends verification code
      @form = request_login_form_class.new(request_client_login_params)
      if @form.valid?
        #TODO: change back to perform_later
        RequestVerificationCodeForLoginJob.perform_now(
          email_address: @form.email_address,
          phone_number: @form.sms_phone_number,
          visitor_id: visitor_id,
          locale: I18n.locale,
          service_type: service_type
        )

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

      verification_code = params[:verification_code]
      @verification_code_form = Portal::VerificationCodeForm.new(contact_info: params[:contact_info], verification_code: verification_code)
      if @verification_code_form.valid?
        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(params[:contact_info], verification_code)
        if Rails.configuration.allow_magic_verification_code && @verification_code_form.verification_code == "000000"
          update_existing_token_with_magic_code(hashed_verification_code)
        end
        @records = client_login_service.login_records_for_token(hashed_verification_code)
        return if redirect_locked_clients # check if any records are already locked
        if @records.present? # we have at least one match and none are locked
          DatadogApi.increment("#{self.controller_name}.verification_codes.right_code")
          redirect_to self.class.to_path_helper(action: :edit, id: hashed_verification_code, **extra_path_params)
          return
        else # we have no matches for the verification code
          @verification_code_form.errors.add(:verification_code, I18n.t("portal.client_logins.form.errors.bad_verification_code"))
          DatadogApi.increment("#{self.controller_name}.verification_codes.wrong_code")
          increment_failed_attempts_on_login_records
          return if redirect_locked_clients
        end
      end

      render :enter_verification_code
    end

    def account_locked; end

    def increment_failed_attempts_on_login_records
      @records = Client.by_contact_info(email_address: params[:portal_verification_code_form][:contact_info], phone_number: params[:portal_verification_code_form][:contact_info])
      @records.map(&:increment_failed_attempts)
    end

    def edit
      # Displays verify SSN form
      @form = ClientLoginForm.new(possible_clients: @records)
    end

    def update
      # Validates SSN
      @form = ClientLoginForm.new(client_login_params)
      if @form.valid?
        sign_in @form.client
        @form.client.accumulate_total_session_durations
        @form.client.touch :last_seen_at
        redirect_to session.delete(:after_client_login_path) || portal_root_path
      else
        @records.each(&:increment_failed_attempts)

        # Re-checking if account is locked after incrementing
        return if redirect_locked_clients

        render :edit
      end
    end

    private

    def request_login_form_class
      RequestClientLoginForm
    end

    def extra_path_params
      {}
    end

    def request_client_login_params
      params.require(:portal_request_client_login_form).permit(:email_address, :sms_phone_number)
    end

    def client_login_params
      params.require(:portal_client_login_form).permit(:last_four_or_client_id).merge(possible_clients: @records)
    end

    def check_verification_code_params
      params.require(:portal_verification_code_form).permit(:contact_info, :verification_code)
    end

    def validate_token
      @records = client_login_service.login_records_for_token(params[:id])
      redirect_to self.class.to_path_helper(action: :create, **extra_path_params) unless @records.present?
    end

    def client_login_service
      ClientLoginService.new(service_type)
    end

    def service_type
      :gyr
    end

    def redirect_locked_clients
      redirect_to account_locked_portal_client_logins_path if @records.map(&:access_locked?).any?
    end

    def redirect_to_portal_if_client_authenticated
      redirect_to portal_root_path if current_client.present?
    end

    def gyr_redirect_unless_open_for_logged_in_clients
      return unless Routes::GyrDomain.new.matches?(request)

      redirect_to portal_closed_login_path unless open_for_gyr_logged_in_clients?
    end

    def update_existing_token_with_magic_code(hashed_verification_code)
      # If the environment supports magic codes, then the easiest thing is to
      # update the last record with the magic code.
      return unless Rails.configuration.allow_magic_verification_code
      if @verification_code_form.contact_info.include?("@")
        tokens = EmailAccessToken.where(email_address: @verification_code_form.contact_info)
      else
        tokens = TextMessageAccessToken.where(sms_phone_number: @verification_code_form.contact_info)
      end
      token = tokens.last
      if token
        token.update(
          token: Devise.token_generator.digest(token.class, :token, hashed_verification_code)
        )
      end
    end
  end
end
