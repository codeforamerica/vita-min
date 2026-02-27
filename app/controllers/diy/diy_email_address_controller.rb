module Diy
  class DiyEmailAddressController < BaseController
    before_action :require_diy_intake

    def edit
      if ! current_diy_intake.email_notification_opt_in_yes?
        redirect_to(diy_continue_to_fsa_path)
      end
      @form = DiyEmailAddressForm.new
    end

    def update
      diy_intake = current_diy_intake
      form_params = params.fetch(:diy_email_address_form, {}).permit(*DiyEmailAddressForm.attribute_names)
      @form = DiyEmailAddressForm.new(diy_intake, form_params)
      if @form.valid?
        @form.save
        after_update_success
        track_question_answer
        redirect_to(diy_continue_to_fsa_path)
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
