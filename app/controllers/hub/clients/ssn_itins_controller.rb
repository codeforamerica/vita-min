module Hub
  module Clients
    class SsnItinsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false

      def show
        AccessLog.create(
          user: current_user,
          client: @client,
          event_type: "read_ssn_itin",
          created_at: DateTime.now,
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )
        respond_to :js
      end

      def hide
        respond_to :js
      end
    end
  end
end
