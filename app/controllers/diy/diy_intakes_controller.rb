module Diy
  class DiyIntakesController < ApplicationController
    before_action :redirect_in_offseason

    def new
      @diy_intake = DiyIntake.new
    end

    def create
      @diy_intake = DiyIntake.new(create_params)

      return render :new unless @diy_intake.save

      session[:diy_intake_id] = @diy_intake.id
      redirect_to(diy_tax_slayer_path)
    end

    private

    def create_params
      params.require(:diy_intake).permit(:email_address, :email_address_confirmation).merge(
        source: source,
        referrer: referrer,
        visitor_id: visitor_id,
        locale: I18n.locale
      )
    end

    def redirect_in_offseason
      redirect_to root_path unless open_for_intake?
    end
  end
end
