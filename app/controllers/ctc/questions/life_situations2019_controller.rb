module Ctc
  module Questions
    class LifeSituations2019Controller < QuestionsController

      layout "intake"

      def self.show?(intake)
        intake.filed_2019_filed_full? || intake.filed_2019_filed_non_filer?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end