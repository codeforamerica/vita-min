module Ctc
  module Questions
    class IrsLanguagePreferenceController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def illustration_path; end
    end
  end
end