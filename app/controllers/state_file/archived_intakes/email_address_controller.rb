module StateFile
  module ArchivedIntakes
    class EmailAddressController < ApplicationController
      def edit
        @form = EmailAddressForm.new
      end

      def update
        email_address = params["state_file_archived_intakes_email_address_form"]["email_address"]
        archived_intake = StateFileArchivedIntake.find_by(email_address: email_address)

        StateFileArchivedIntakeAccessLog.create!(
          ip_address: ip_for_irs,
          details: { email_address: email_address },
          event_type: 0
        )

      end
    end
  end
end
