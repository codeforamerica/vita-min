module Hub
  module Clients
    class OrganizationsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      before_action :load_vita_partners, only: [:edit, :update]
      before_action :authorize_vita_partner, only: [:update]

      layout "admin"
      load_and_authorize_resource :client, parent: false

      def edit; end

      def update
        if @client.update(client_params)
          redirect_to hub_client_path(id: @client.id)
        else
          render :edit
        end
      end

      private

      def client_params
        params.require(:client).permit(:vita_partner_id).merge(change_initiated_by: current_user)
      end

      def load_vita_partners
        @vita_partners = VitaPartner.accessible_by(current_ability)
      end

      def authorize_vita_partner
        raise CanCan::AccessDenied unless @vita_partners.find_by(id: client_params[:vita_partner_id]).present?
      end
    end
  end
end
