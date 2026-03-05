module Diy
  class DiyInitialInfoController < BaseController
    before_action :require_diy_intake

    def edit
      @form = DiyInitialInfoForm.new
    end

    def update
      diy_intake = current_diy_intake
      form_params = params.fetch(:diy_initial_info_form, {}).permit(*DiyInitialInfoForm.attribute_names)
      @form = DiyInitialInfoForm.new(diy_intake, form_params)
      if @form.valid?
        @form.save
        after_update_success
        track_question_answer
        redirect_to(diy_diy_notification_preference_path)
      else
        after_update_failure
        track_validation_error
        render :edit
      end
    end

    private

    def tracking_data
      {}
    end
  end
end
