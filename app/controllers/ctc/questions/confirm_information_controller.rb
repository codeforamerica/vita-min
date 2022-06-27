module Ctc
  module Questions
    class ConfirmInformationController < QuestionsController
      include AuthenticatedCtcClientConcern
      before_action :verify_address, only: :edit

      layout "intake"

      def illustration_path
        "successfully-submitted.svg"
      end

      def verify_address
        return if current_intake.client_confirmed_address.present?

        address_service = StandardizeAddressService.new(@intake, read_timeout: 1000)
        # not sure whether to also check address_service.valid? here
        if !address_service.has_verified_address?
          session[:confirm_info_found_address_error] = true
          session[:address_service] = address_service
        else
          #  do we save the valid address or...??
        end
      end
    end
  end
end
