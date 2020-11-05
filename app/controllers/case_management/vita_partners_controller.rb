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

    def edit; end

    def update; end

    def create_sub_organization
      case request.method_symbol
      when :get
        @form = SubOrganizationForm.new(VitaPartner.new)
      when :post
        params = form_params
        params[:parent_organization_id] = @vita_partner.id
        @form = SubOrganizationForm.new(VitaPartner.new, params)
        if @form.valid?
          @form.save
          redirect_to case_management_vita_partner_path(id: @vita_partner.id)
        end
      end
    end

    def form_params
      params.require(:case_management_sub_organization_form).permit(:display_name)
    end
  end
end
