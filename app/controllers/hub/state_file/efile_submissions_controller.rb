module Hub
  module StateFile
    class EfileSubmissionsController < Hub::BaseController
      before_action :require_state_file
      before_action :load_efile_submissions
      load_and_authorize_resource
      layout "hub"

      def index
      end

      def show
      end

      private

      def load_efile_submissions
        @efile_submissions = EfileSubmission.for_state_filing
      end
    end
  end
end
