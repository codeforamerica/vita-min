module Ctc
  module Questions
    class ConsentController < QuestionsController
      include FirstQuestionConcern
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      def form_params
        super.merge(ip_address: request.remote_ip)
      end

      private

      def illustration_path; end
    end
  end
end
