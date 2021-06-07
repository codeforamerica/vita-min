module Hub
  class CtcClientsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    before_action :load_vita_partners, only: [:new, :create, :index]
    layout "admin"

    def new
      @form = CreateCtcClientForm.new
    end

    def create
      @form = CreateCtcClientForm.new(create_client_form_params)
      assigned_vita_partner = VitaPartner.find_by(id: create_client_form_params["vita_partner_id"])

      if can?(:read, assigned_vita_partner) && @form.save(current_user)
        flash[:notice] = I18n.t("hub.clients.create.success_message")
        redirect_to hub_client_path(id: @form.client)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :new
      end
    end

    private

    def create_client_form_params
      params.require(CreateCtcClientForm.form_param).permit(CreateCtcClientForm.permitted_params)
    end
  end
end