module Diy
  class DiyNotificationPreferenceController < BaseController
    before_action :require_diy_intake

    def edit
      @form = DiyNotificationPreferenceForm.new
    end

    def update
      diy_intake = current_diy_intake
      form_params = params.fetch(:diy_notification_preference_form, {}).permit(*DiyNotificationPreferenceForm.attribute_names)
      @form = DiyNotificationPreferenceForm.new(diy_intake, form_params)
      if @form.valid?
        @form.save
        after_update_success
        track_question_answer
        session[:diy_intake_id] = diy_intake.id
        redirect_to(diy_continue_to_fsa_path)
      else
        after_update_failure
        track_validation_error
        render :edit
      end
    end

    private
   
    def tracking_data
      @form.attributes_for(:diy_intake).reject { |k, _| k == :sms_phone_number }
    end
  end
end
