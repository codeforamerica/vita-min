module Diy
  class FileYourselfController < BaseController
    def edit
      @form = FileYourselfForm.new
    end

    def update
      @form = FileYourselfForm.new(DiyIntake.find(session[:diy_intake_id]) || DiyIntake.new, create_params)

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
