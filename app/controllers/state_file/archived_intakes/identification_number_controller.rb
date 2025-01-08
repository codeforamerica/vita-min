# 1. use front end validations for SSN
# 2. give them 1 attempt at an inccorect SSN
# 3. update the access logs to have the correct event
# 4. tests, translations
module StateFile
  module ArchivedIntakes
    class IdentificationNumberController < ApplicationController
      def edit
        @form = IdentificationNumberForm.new
        render :edit
      end

      def update
        @form = IdentificationNumberForm.new(identification_number_form_params)
        hashed_ssn = SsnHashingService.hash(identification_number_form_params[:ssn])
          archived_intake = StateFileArchivedIntake.find_by(email_address: session[:archived_intake_email_address])

        if hashed_ssn == archived_intake.hashed_ssn
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            details: { hashed_ssn: @form.email_address },
            event_type: 0,
            state_file_archived_intake: archived_intake
          )
        else
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            details: { hashed_ssn: @form.email_address },
            event_type: 0,
          )
        end
      end

      def identification_number_form_params
        params.require(:state_file_archived_intakes_identification_number_form).permit(:ssn)
      end
    end
  end
end
