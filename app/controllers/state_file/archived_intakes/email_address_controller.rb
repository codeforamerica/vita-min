module StateFile
  module ArchivedIntakes
    class EmailAddressController < ArchivedIntakeController
      before_action :check_feature_flag
      def edit
        @form = EmailAddressForm.new
      end

      def update
        @form = EmailAddressForm.new(email_address_form_params)

        if @form.save
          archived_intake = StateFileArchivedIntake.find_by(email_address: @form.email_address)
          request = StateFileArchivedIntakeRequest.find_or_create_by(email_address: @form.email_address, ip_address: ip_for_irs, state_file_archived_intakes_id: archived_intake&.id )
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            event_type: 0,
            state_file_archived_intake_request: request
          )

          redirect_to state_file_archived_intakes_edit_verification_code_path
        else
          render :edit
        end
      end

      private

      def email_address_form_params
        params.require(:state_file_archived_intakes_email_address_form).permit(:email_address)
      end

      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end

    end
  end
end
