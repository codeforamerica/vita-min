module Ctc
  module Questions
    class ConfirmMailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def self.show?(intake)
        # TODO: what to do for people from before we made this change???
        intake.usps_address_verified_at
      end

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end