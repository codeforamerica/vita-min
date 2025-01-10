module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      def current_request
        StateFileArchivedIntakeRequest.where(ip_address: ip_for_irs).order(created_at: :desc).first
      end

      def create_state_file_access_log(event_type)
        StateFileArchivedIntakeAccessLog.create!(
          event_type: event_type,
          state_file_archived_intake_request: current_request
        )
      end
    end
  end
end
