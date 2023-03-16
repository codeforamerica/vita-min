module Diy
  class FileYourselfController < BaseController
    def edit
      @diy_intake = DiyIntake.new
    end

    def update
      @diy_intake = DiyIntake.new(create_params)

      # TODO: is this janky? answer: i think yes
      return render :edit unless params[:diy_intake].keys.all? { |param| params[:diy_intake][param].present? }
      return render :edit unless @diy_intake.save

      session[:diy_intake_id] = @diy_intake.id
      redirect_to(diy_continue_to_fsa_path)
    end

    private

    def create_params
      params.require(:diy_intake).permit(:preferred_first_name, :email_address, :received_1099, :filing_frequency).merge(
        source: source,
        referrer: referrer,
        visitor_id: visitor_id,
        locale: I18n.locale
      )
    end
  end
end
