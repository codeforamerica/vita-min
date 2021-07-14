module Ctc
  module Questions
    class SpouseSsnController < QuestionsController
      include AnonymousIntakeConcern
      layout "yes_no_question"

      private

      def illustration_path
        "social-security-card.svg"
      end

      def self.form_class
        NullForm
      end
    end
  end
end