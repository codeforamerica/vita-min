module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def index
      @coalitions = Coalition.includes(:organizations)
      @independent_organizations = @organizations.where(coalition: nil)
    end

    def new
      @coalitions = Coalition.all
    end

    def create
      render :new unless @organization.save

      redirect_to hub_organizations_path
    end

    def edit
      @coalitions = Coalition.all
    end

    def update
      render :edit unless @organization.update(organization_params)

      redirect_to hub_organizations_path
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :coalition_id)
    end
  end
end
