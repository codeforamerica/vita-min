module Ctc
  module Questions
    class IrsLanguagePreferenceController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def illustration_path; end
    end
  end
end