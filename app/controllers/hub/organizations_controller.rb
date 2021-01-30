module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def new
      @coalitions = Coalition.all
      @organization = @vita_partner
    end

    def create
      if @vita_partner.save
        redirect_to hub_organizations_path
      else
        @coalitions = Coalition.all
        render :new
      end
    end

    def show
      @organization = VitaPartner.organizations.find(params[:id])
      @sites = @organization.child_sites
    end

    def index
      @coalitions = Coalition.accessible_by(current_ability).includes(:organizations)
      @organizations = @vita_partners.organizations
      @independent_organizations = @vita_partners.organizations.where(coalition: nil)
    end

    def edit
      @coalitions = Coalition.all
      @organization = @vita_partner
    end

    def update
      if @vita_partner.update(vita_partner_params)
        redirect_to edit_hub_organization_path(id: @vita_partner.id)
      else
        @coalitions = Coalition.all
        @organization = @vita_partner
        render :edit
      end
    end

    private

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :coalition_id, source_parameters_attributes: [:_destroy, :id, :code])
    end
  end
end
