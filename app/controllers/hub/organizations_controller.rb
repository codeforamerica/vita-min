module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def new
      @coalitions = Coalition.all
    end

    def create
      render :new unless @vita_partner.save!

      redirect_to hub_organizations_path
    end

    def index
      @coalitions = Coalition.includes(:organizations)
      @organizations = @vita_partners.organizations
      @independent_organizations = @vita_partners.organizations.where(coalition: nil)
    end

    private

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :coalition_id).merge(
        zendesk_group_id: "unused",
        zendesk_instance_domain: "unused"
      )
    end
  end
end
