module Ctc
  module Questions
    class ConfirmMailingAddressController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end