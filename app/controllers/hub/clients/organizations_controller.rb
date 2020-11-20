module Hub
  module Clients
    class OrganizationsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in

      layout "admin"
      load_and_authorize_resource :client, parent: false
      load_and_authorize_resource :vita_partner, collection: [:edit, :update], parent: false

      def edit;end

      def update
        @client.update(client_params)
        redirect_to hub_client_path(id: @client.id)
      end

      def client_params
        params.require(:client).permit(:vita_partner_id)
      end
    end
  end
end