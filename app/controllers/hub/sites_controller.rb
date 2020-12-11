module Hub
  class SitesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_organizations, only: [:new, :edit]

    load_and_authorize_resource :organization
    load_and_authorize_resource through: :organization

    layout "admin"

    def new; end

    def create
      @site = Site.new(site_params)
      render :new unless @site.save

      redirect_to edit_hub_organization_path(id: @site.organization)
    end

    def edit; end

    def update
      render :edit unless @site.update(site_params)

      redirect_to edit_hub_organization_path(id: @site.organization_id)
    end

    private

    def load_organizations
      @organizations = Organization.accessible_by(current_ability)
    end

    def site_params
      params.require(:site).permit(:name, :organization_id)
    end
  end
end

