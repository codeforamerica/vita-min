module Hub
  class SitesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :load_organizations, only: [:new, :edit, :update]

    load_and_authorize_resource :site, parent: false

    layout "hub"

    def new
      @site = Site.new(parent_organization_id: params[:parent_organization_id])
    end

    def create
      @site = Site.new(site_params)
      if @site.save
        redirect_to edit_hub_organization_path(id: @site.parent_organization)
      else
        render :new
      end
    end

    def edit
      @routing_form = ZipCodeRoutingForm.new(@site)
      @source_params_form = SourceParamsForm.new(@site)
      @show_unique_links = true
    end

    def update
      if @site.update(site_params)
        flash[:notice] = I18n.t("general.changes_saved")
        redirect_to edit_hub_site_path(id: @site.id)
      else
        @show_unique_links = true
        flash.now[:alert] = I18n.t("general.error.form_failed")
        render :edit
      end
    end

    private

    def load_organizations
      @organizations = VitaPartner.accessible_by(current_ability).organizations
    end

    def site_params
      params.require(:site).permit(:name, :parent_organization_id, :timezone, :accepts_itin_applicants, source_parameters_attributes: [:_destroy, :id, :code])
    end
  end
end
