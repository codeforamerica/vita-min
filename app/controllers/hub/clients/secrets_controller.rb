module Hub
  module Clients
    class SecretsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false
      respond_to :js

      def show
        @partial_params = {}
        if params[:secret_name] == 'primary_ssn'
          @partial_path = 'hub/clients/displayed_ssn_itin'
        elsif params[:secret_name] == 'spouse_ssn'
          @partial_path = 'hub/clients/displayed_spouse_ssn_itin'
        elsif params[:secret_name] == 'dependent_ssn'
          @partial_path = 'hub/clients/displayed_dependent_ssn_itin'
          @partial_params = { locals: { dependent: @client.intake.dependents.find(params[:secret_record_id]) } }
        else
          raise ActionController::RoutingError.new('Not Found')
        end

        create_access_log
      end

      def hide
        @partial_path = 'hub/clients/hidden_ssn_itin'
      end

      private

      def id_suffix
        [params[:secret_name], params[:secret_record_id]].compact.join('-')
      end

      helper_method :id_suffix

      def create_access_log
        AccessLog.create!(
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
