module CaseManagement
  class SubOrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :vita_partner, parent: false
    layout "admin"

    def update
      @form = SubOrganizationForm.new(VitaPartner.new, form_params)
      if @form.valid?
        @form.save
        redirect_to case_management_vita_partner_path(id: @vita_partner.id)
      else
        render :edit
      end
    end

    def edit
      @form = SubOrganizationForm.new(VitaPartner.new)
    end

    private

    def form_params
      params.require(:case_management_sub_organization_form).permit(SubOrganizationForm.attribute_names).merge(parent_organization_id: @vita_partner.id)
    end
  end
end
