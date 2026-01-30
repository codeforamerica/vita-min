module Diy
  class DiyNotificationPreferenceController < BaseController
    def edit
      @form = DiyNotificationPreferenceForm.new
    end

    def update
      diy_intake = current_diy_intake
      @form = DiyNotificationPreferenceForm.new(diy_intake)
      if @form.valid?
        @form.save
        session[:diy_intake_id] = diy_intake.id
        redirect_to(diy_continue_to_fsa_path)
      else
        render :edit
      end
    end

    private

    def tracking_data
      @form.attributes_for(:diy_intake)
    end

    def illustration_path
      "contact-preference.svg"
    end
  end
end
