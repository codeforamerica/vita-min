module Ctc
  module Questions
    class ConfirmMailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(_)
        session[:address_usps_verified]
      end

      private

      def next_path
        if session[:return_to_confirmation_page]
          questions_confirm_information_path
        else
          super
        end
      end

      def form_class
        NullForm
      end

      def illustration_path; end

      def after_update_success
        Address.create(
          city: current_intake.city,
          state: current_intake.state,
          street_address: current_intake.street_address,
          street_address2: current_intake.street_address2,
          zip_code: current_intake.zip_code,
          intake: current_intake,
        )
      end
    end
  end
end