module Hub
  module Clients
    class OrganizationsController < Hub::BaseController
      load_and_authorize_resource :client, parent: false
      before_action :redirect_to_client_show_if_archived
      before_action :redirect_if_no_vita_partner_selected, only: [:update]
      before_action :load_vita_partners, only: [:edit, :update]
      before_action :load_vita_partner, only: [:update]
      layout "hub"

      def edit; end

      def update
        begin
          ActiveRecord::Base.transaction do
            UpdateClientVitaPartnerService.new(clients: [@client],
                                               vita_partner_id: @vita_partner.id,
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

      def load_vita_partner
        begin
          id = JSON.parse(client_params[:vita_partners]).pluck("id").first
          @vita_partner = @vita_partners.find(id)
        rescue ActiveRecord::RecordNotFound
          head :forbidden
        end
      end

      def redirect_to_client_show_if_archived
        redirect_to hub_client_path(@client.id) unless @client.intake
      end

      def redirect_if_no_vita_partner_selected
        return if client_params[:vita_partners].present?

        flash[:alert] = "No changes made because no organization selected for client."
        redirect_to hub_client_path(@client.id)
      end
    end
  end
end
