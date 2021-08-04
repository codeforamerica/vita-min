module Ctc
  module Questions
    class HomeController < QuestionsController

      private

      def illustration_path; end

      def next_path
        @form.lived_in_territory_or_at_foreign_address? ? questions_use_gyr_path : super
      end
    end
  end
end