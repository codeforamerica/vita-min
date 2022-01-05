module Hub
  module Clients
    class OrganizationsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      before_action :load_vita_partners, only: [:edit, :update]
      before_action :authorize_vita_partner, only: [:update]

      layout "hub"
      load_and_authorize_resource :client, parent: false
      before_action :redirect_to_client_show_if_archived

      def edit; end

      def update
        begin
          ActiveRecord::Base.transaction do
            UpdateClientVitaPartnerService.new(clients: [@client],
                                               vita_partner_id: client_params[:vita_partner_id],
                                               change_initiated_by: current_user).update!
          end
        rescue ActiveRecord::RecordInvalid
          render :edit
        else
          redirect_to hub_client_path(id: @client.id)
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

      def redirect_to_client_show_if_archived
        redirect_to hub_client_path(@client.id) unless @client.intake
      end
    end
  end
end
