module Hub
  module Clients
    class OrganizationsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource :client, parent: false
      before_action :redirect_to_client_show_if_archived
      before_action :redirect_if_no_vita_partner_selected, only: [:update]
      before_action :load_vita_partners, only: [:edit, :update]
      before_action :authorize_vita_partner, only: [:update]
      layout "hub"

      def edit; end

      def update
        begin
          ActiveRecord::Base.transaction do
            UpdateClientVitaPartnerService.new(clients: [@client],
                                               vita_partner_id: parsed_vita_partner_id,
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
        params.require(:client).permit(:vita_partners).merge(change_initiated_by: current_user)
      end

      def load_vita_partners
        @vita_partners = VitaPartner.accessible_by(current_ability)
      end

      def authorize_vita_partner
        raise CanCan::AccessDenied unless @vita_partners.find_by(id: parsed_vita_partner_id).present?
      end

      def parsed_vita_partner_id
        return nil unless client_params[:vita_partners].present?
        JSON.parse(client_params[:vita_partners]).pluck("id")
      end

      def redirect_to_client_show_if_archived
        redirect_to hub_client_path(@client.id) unless @client.intake
      end

      def redirect_if_no_vita_partner_selected
        return if client_params[:vita_partners].present?

        flash[:alert] = "No changes made because no vita partner selected."
        redirect_to hub_client_path(@client.id)
      end
    end
  end
end
