module Portal
  class ClientLoginsController < ApplicationController
    include MessageSending

    before_action :ensure_valid_token, only: [:edit, :update]

    def new
      @form = RequestClientLoginForm.new
    end

    def abruptly_sign_in_client
      sign_in Client.last
    end

    def whoami_client
      render plain: current_client&.id
    end

    def create
      @form = RequestClientLoginForm.new(request_client_login_form_params)
      if @form.valid?
        # generate a new token
        raw_token, encrypted_token = Devise.token_generator.generate(Client, :login_token)

        # update records with the token and request time
        clients_with_email_or_phone_number.update(
          login_token: encrypted_token,
          login_requested_at: DateTime.now
        )

        # get link
        client_login_link = edit_portal_client_login_path(token: raw_token)

        # send to contact info
        ClientLoginRequestMailer.with(login_link: client_login_link).client_login_email.deliver_later if @form.email_address.present?
        send_system_text_message("Login here: #{login_link}") if @form.phone_number.present?

        redirect_to portal_client_login_link_sent_path
      else
        render :new
      end
    end

    def link_sent; end

    def edit
      @form = ClientLoginForm.new(token: @raw_token)
    end

    def update
      @form = ClientLoginForm.new(client_login_form_params)
      if @form.valid?
        # how to we do a lookup based on ssn?
        @client = @clients.where(id: @form.confirmation_number)

        # authenticate the client
        sign_in @client

        redirect_to portal_root_path
      else
        render :edit
      end
    end

    private

    def ensure_valid_token
      @raw_token = params[:token]
      if @raw_token.present?
        encrypted_token = Devise.token_generator.digest(Client, :login_token, @raw_token)
        @clients = Client.where(login_token: encrypted_token)
      end
      raise StandardError("invalid token") unless @clients.present?
    end

    def client_login_form_params
      params.require(:client_login_form).permit(:last_four_ssn, :confirmation_number, :token)
    end

    def request_client_login_form_params
      params.require(:request_client_login_form).permit(:email_address, :phone_number)
    end

    def clients_with_email_or_phone_number
      # all relevant clients?
      relevant_intakes = Intake.where(
        email_address: @form.email_address
      ).or(
        Intake.where(spouse_email_address: @form.email_address)
      ).or(
        Intake.where(phone_number: @form.phone_number)
      ).or(
        Intake.where(sms_phone_number: @form.phone_number)
      )
      Client.where(intake: relevant_intakes)
    end
  end
end