module Diy
  class DiyNotificationPreferenceController < BaseController
    def edit
      @form = DiyNotificationPreferenceForm.new
    end

    def update
      diy_intake = current_diy_intake
      form_params = params.fetch(:diy_notification_preference_form, {}).permit(*DiyNotificationPreferenceForm.attribute_names)
      @form = DiyNotificationPreferenceForm.new(diy_intake, form_params)
      if @form.valid?
        @form.save
        session[:diy_intake_id] = diy_intake.id
        redirect_to(diy_continue_to_fsa_path)
      else
        render :edit
      end
    end
  end
end
