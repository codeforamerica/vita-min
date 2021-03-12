module Hub
  module Clients
    class SsnItinsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false
      respond_to :js

      def show
        create_access_log
      end

      def hide; end

      def show_spouse
        create_access_log
      end

      def hide_spouse; end

      private

      def create_access_log
        AccessLog.create(
          user: current_user,
          record: @client,
          event_type: "read_ssn_itin",
          created_at: DateTime.now,
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )
      end
    end
  end
end
