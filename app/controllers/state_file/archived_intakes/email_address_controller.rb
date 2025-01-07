module StateFile
  module ArchivedIntakes
    class EmailAddressController < ApplicationController
      def edit
        @form = EmailAddressForm.new
      end

      def update
        @form = EmailAddressForm.new(email_address_form_params)

        if @form.save

          archived_intake = StateFileArchivedIntake.find_by(email_address: @form.email_address)

          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            details: { email_address: @form.email_address },
            event_type: 0,
            state_file_archived_intake: archived_intake
          )
          redirect_to state_file_archived_intakes_edit_verification_code_path(email_address: @form.email_address)
        else
          render :edit
        end
      end

      private

      def email_address_form_params
        params.require(:state_file_archived_intakes_email_address_form).permit(:email_address)
      end
    end
  end
end
