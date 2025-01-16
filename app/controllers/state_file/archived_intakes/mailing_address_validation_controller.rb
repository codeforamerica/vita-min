require 'csv'

module StateFile
  module ArchivedIntakes
    class MailingAddressValidationController < ArchivedIntakeController
      def edit
        intake = current_request.state_file_archived_intake
        address_challenge_generate(intake)
      end

      def address_challenge_generate(intake)
        file_path = Rails.root.join('app', 'lib', 'addresses.csv')
        addresses = CSV.read(file_path, headers: true)
        random_address = addresses.sample
        binding.pry
      end
    end
  end
end