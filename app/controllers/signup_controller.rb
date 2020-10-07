class SignupController < ApplicationController
  def create
    Signup.create!(signup_params)
    send_mixpanel_event(event_name: "2021-sign-up")
  end

  def index
    @signup = Signup.new
  end

  private

  def signup_params
    params.require(:signup).permit(:name, :zip_code, :email_address, :phone_number)
  end
end