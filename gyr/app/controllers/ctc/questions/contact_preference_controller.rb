module Ctc
  module Questions
    class ContactPreferenceController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def form_class
        NullForm
      end
    end
  end
end
