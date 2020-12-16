module Hub
  class SitesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_organizations, only: [:new, :edit]

    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def new
      @site = VitaPartner.new(parent_organization_id: params[:parent_organization_id])
    end

    def create
      @site = VitaPartner.new(vita_partner_params)
      if @site.save
        redirect_to edit_hub_organization_path(id: @site.parent_organization)
      else
        render :new
      end
    end

    def edit
      @site = @vita_partner
    end

    def update
      render :edit unless @vita_partner.update(vita_partner_params)

      redirect_to edit_hub_organization_path(id: @vita_partner.parent_organization_id)
    end

    private

    def load_organizations
      @organizations = VitaPartner.accessible_by(current_ability).organizations
    end

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :parent_organization_id).merge(
        zendesk_instance_domain: "unused",
        zendesk_group_id: "unused",
      )
    end
  end
end
