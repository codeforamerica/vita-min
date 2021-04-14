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
      @vita_partners = @vita_partners.organizations.includes(:organization_capacity)
      @organizations = @vita_partners
      @independent_organizations = @vita_partners.organizations.includes(:organization_capacity).where(coalition: nil)
    end

    def edit
      @coalitions = Coalition.all
      @organization = @vita_partner
    end

    def update
      if @vita_partner.update(vita_partner_params)
        flash[:notice] = I18n.t("general.changes_saved")
        redirect_to edit_hub_organization_path(id: @vita_partner.id)
      else
        @coalitions = Coalition.all
        @organization = @vita_partner
        flash.now[:alert] = I18n.t("general.error.form_failed")
        render :edit
      end
    end

    private

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :coalition_id, :timezone, :capacity_limit, :allows_greeters, source_parameters_attributes: [:_destroy, :id, :code])
    end
  end
end
