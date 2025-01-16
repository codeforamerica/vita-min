# 1. use front end validations for SSN
# 2. give them 1 attempt at an inccorect SSN
# 3. update the access logs to have the correct event
# 4. tests
# 5. translations
# 6. remove the session and use the path to pass the email address
module StateFile
  module ArchivedIntakes
    class IdentificationNumberController < ApplicationController
      def edit
        archived_intake = StateFileArchivedIntake.find_by(email_address: session[:email_address])
        @form = IdentificationNumberForm.new({}, archived_intake&.hashed_ssn)
        render :edit
      end

      def update
        archived_intake = StateFileArchivedIntake.find_by(email_address: session[:email_address])

        @form = IdentificationNumberForm.new(
          identification_number_form_params.merge(ip_for_irs: request.remote_ip),
          archived_intake&.hashed_ssn
        )

        # validates if we have an associated SSN with the intake
        # if yes, great! keep on keeping on
        # if no, we record that attempt, we check how many attempts they have made
        # first attempt: we throw the validation error
        # second attempt: we offboard, we can't find their account

        if @form.valid?
          redirect_to root_path
          #need to add address challaned
        else
          if @form.errors.include?(:no_remaining_attempts)
            redirect_to offboarding_path
          else
            render :edit
          end
        end


        #
        # archived_intake = StateFileArchivedIntake.find_by(email_address: session[:email_address])
        # hashed_ssn = SsnHashingService.hash(identification_number_form_params[:ssn])
        #
        # if hashed_ssn == archived_intake.hashed_ssn
        #   StateFileArchivedIntakeAccessLog.create!(
        #     ip_address: ip_for_irs,
        #     details: { hashed_ssn: @form.email_address },
        #     event_type: 4,
        #     state_file_archived_intake: archived_intake
        #   )
        #   redirect_to root_path
        # else
        #   # create a failed attempt
        #   StateFileArchivedIntakeAccessLog.create!(
        #     ip_address: ip_for_irs,
        #     details: { hashed_ssn: @form.email_address },
        #     event_type: 5,
        #   )
        #
        #   # check if there are other failed attempts
        #   attempts = StateFileArchivedIntakeAccessLog.where(
        #     ip_address: ip_for_irs,
        #     event_type: 5,
        #     created_at: Time.now - 5 # less than 1 hour
        #   ).count
        #   if attempts >= 2
        #     # lock them out
        #   else
        #     render :edit
        #     # show the page again with a validation error showing remaining attempts
        #   end
        # end
      end

      def identification_number_form_params
        params.require(:state_file_archived_intakes_identification_number_form).permit(:ssn)
      end
    end
  end
end
