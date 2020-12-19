module Hub
  module Clients
    class BankAccountsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false

      def show
        AccessLog.create(
          user: current_user,
          client: @client,
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
