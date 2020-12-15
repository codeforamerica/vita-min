module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :vita_partner

    layout "admin"

    def new
      @coalitions = Coalition.all
    end

    def create
      render :new unless @vita_partner.save

      redirect_to hub_organizations_path
    end

    def index
      @coalitions = Coalition.includes(:organizations)
      @independent_organizations = @organizations.where(coalition: nil)
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :coalition_id)
    end
  end
end
