module CaseManagement
  class VitaPartnersController < ApplicationController

    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def index
      @vita_partners = @vita_partners.where(parent_organization: nil)
    end

    def show
      @sub_organizations = @vita_partner.sub_organizations
    end
  end
end
