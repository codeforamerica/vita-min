module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      def current_request
        StateFileArchivedIntakeRequest.where(ip_address: ip_for_irs).order(created_at: :desc).first
      end
    end
  end
end
