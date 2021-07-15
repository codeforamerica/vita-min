module Ctc
  module Questions
    class SpouseInfoController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      private

      def next_path
        return questions_use_gyr_path if @form.intake.spouse_tin_type_none?

        super
      end

      def illustration_path; end

    end
  end
end