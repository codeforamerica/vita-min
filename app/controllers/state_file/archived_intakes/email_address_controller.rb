module StateFile
  module ArchivedIntakes
    class EmailAddressController < ApplicationController
      def edit
        @form = EmailAddressForm.new
      end

      def update
        @form = EmailAddressForm.new(email_address_form_params)

        if @form.save
          # Assuming you need to log or handle successful form submissions
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            details: { email_address: @form.email_address },
            event_type: 0
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
    end
  end
end
