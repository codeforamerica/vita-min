module Hub
  module Clients
    class BankAccountsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false

      def show
        # must load bank account through intake because of unpersisted BankAccount object for GYRIntake
        @bank_account = @client.intake.bank_account
        AccessLog.create!(
          user: current_user,
          record: @client,
          created_at: DateTime.now,
          event_type: "read_bank_account_info",
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )
        respond_to :js
      end

      def hide
        @bank_account = @client.intake.bank_account
        respond_to :js
      end
    end
  end
end
