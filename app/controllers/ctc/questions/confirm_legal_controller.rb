module Ctc
  module Questions
    class ConfirmLegalController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def form_params
        super.merge(ip_address: request.remote_ip)
      end

      private

      def next_path
        ctc_portal_root_path
      end

      def illustration_path
        "successfully-submitted.svg"
      end
    end
  end
end
