require 'csv'

module StateFile
  module ArchivedIntakes
    class MailingAddressValidationController < ArchivedIntakeController
      def edit
        create_state_file_access_log("issued_mailing_address_challenge")
        @addresses = generate_address_options
        @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_archived_intake.full_address)
      end

      def update
        @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_archived_intake.full_address)

        if @form.valid?
          create_state_file_access_log("correct_mailing_address")
          # this should take us to the download
          redirect_to root_path
        else
          create_state_file_access_log("incorrect_mailing_address")
          current_request.lock_access!
          #this should be to the offboaring page
          redirect_to faq_path
        end
      end

      def generate_address_options
        file_path = Rails.root.join('app', 'lib', 'challenge_addresses', "#{current_archived_intake.mailing_state.downcase}_addresses.csv")
        addresses = CSV.read(file_path, headers: false).flatten
        random_addresses = addresses.sample(2)
        (random_addresses + [current_archived_intake.full_address]).shuffle
      end

      private

      def mailing_address_validation_form_params
        params.require(:state_file_archived_intakes_mailing_address_validation_form).permit(:selected_address)
      end
    end
  end
end
