module Ctc
  class SignupsController < CtcController
    def create
      @signup = CtcSignup.new(signup_params)

      if @signup.save
        send_mixpanel_event(event_name: "2021-ctc-sign-up")
        redirect_to confirmation_ctc_signups_path
      else
        send_mixpanel_validation_error(@signup.errors)
        render :new
      end
    end

    def new
      @signup = CtcSignup.new
    end

    def confirmation; end

    private

    def signup_params
      permitted_params = params.require(:ctc_signup).permit(:name, :email_address, :phone_number)
      permitted_params.merge(phone_number: PhoneParser.normalize(permitted_params[:phone_number]))
    end
  end
end
