module Ctc
  module Questions
    class SpouseDriversLicenseController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def show?; end

      def illustration_path
        "ids.svg"
      end
    end
  end
end
