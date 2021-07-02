module Hub
  module Clients
    class IpPinsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false

      def show
        # AccessLog.create!(
        #   user: current_user,
        #   record: @client,
        #   created_at: DateTime.now,
        #   event_type: "read_bank_account_info",
        #   ip_address: request.remote_ip,
        #   user_agent: request.user_agent,
        # )
        respond_to :js
      end

      def hide
        respond_to :js
      end
    end
  end
end
