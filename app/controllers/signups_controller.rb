class SignupsController < ApplicationController
  def create
    @signup = Signup.new(signup_params)

    if @signup.save
      send_mixpanel_event(event_name: "2021-sign-up")
      flash[:notice] = I18n.t("signups.flash_notice")
      redirect_to root_path
    else
      send_mixpanel_validation_error(@signup.errors)
      render :new
    end
  end

  def new
    @signup = Signup.new
  end

  private

  def signup_params
    params.require(:signup).permit(:name, :zip_code, :email_address, :phone_number)
  end
end