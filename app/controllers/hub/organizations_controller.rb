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

    def index
      @coalitions = Coalition.includes(:organizations)
      @organizations = @vita_partners.organizations
      @independent_organizations = @vita_partners.organizations.where(coalition: nil)
    end

    def edit
      @coalitions = Coalition.all
      @organization = @vita_partner
    end

    def update
      render :edit unless @vita_partner.update(vita_partner_params)

      redirect_to hub_organizations_path
    end

    private

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :coalition_id)
    end
  end
end
