module Diy
  class DiyEmailAddressController < BaseController
    before_action :require_diy_intake

    def edit
      redirect_to diy_continue_to_fsa_path unless current_diy_intake.email_notification_opt_in_yes?

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

    def after_update_success
      current_diy_intake.create_or_update_campaign_contact

      if Flipper.enabled?(:send_diy_survey)
        contact = current_diy_intake.campaign_contact
        return unless contact.present?

        CampaignEmail.create(
          campaign_contact_id: contact.id,
          message_name: "diy_followup_survey",
          to_email: contact.email_address,
          scheduled_send_at: Time.current + 1.day
        )
      end
    end

    private

    def tracking_data
      {}
    end
  end
end
