module Ctc
  module Questions
    class DriversLicenseController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def show?; end

      def illustration_path
        "ids.svg"
      end
    end
  end
end
