module Diy
  class DiyCellPhoneNumberController < BaseController
    before_action :require_diy_intake

    def edit
      @form = DiyCellPhoneNumberForm.new
    end

    def update
      diy_intake = current_diy_intake
      form_params = params.fetch(:diy_cell_phone_number_form, {}).permit(*DiyCellPhoneNumberForm.attribute_names)
      @form = DiyCellPhoneNumberForm.new(diy_intake, form_params)
      if @form.valid?
        @form.save
        redirect_to(diy_continue_to_fsa_path)
      else
        render :edit
      end
    end

    private

    def tracking_data
      {}
    end

    def self.show?(diy_intake)
      diy_intake.sms_phone_number.blank? && diy_intake.sms_notification_opt_in_yes?
    end

    def after_update_success
      if @form.diy_intake.sms_notification_opt_in_yes?
        ClientMessagingService.send_system_text_message(
          client: @form.diy_intake.client,
          body: I18n.t("messages.sms_opt_in")
        )
      end
    end
  end
end
