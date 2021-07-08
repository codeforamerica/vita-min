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

        if params[:save_and_add]
          redirect_to new_hub_ctc_client_path
        else
          redirect_to hub_client_path(id: @form.client)
        end
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :new
      end
    end

    def edit
      @client = Client.find(params[:id])
      return render "public_pages/page_not_found", status: 404 unless @client.intake.is_ctc?

      @form = UpdateCtcClientForm.from_client(@client)
    end

    def update
      @client = Client.find(params[:id])
      @form = UpdateCtcClientForm.new(@client, update_client_form_params)

      if @form.valid? && @form.save
        SystemNote::ClientChange.generate!(initiated_by: current_user, intake: @client.intake)
        redirect_to hub_client_path(id: @client.id)
      else
        flash[:alert] = I18n.t("forms.errors.general")
        render :edit
      end
    end

    private

    def load_vita_partners
      @vita_partners = super.where(processes_ctc: true)
    end

    def create_client_form_params
      params.require(CreateCtcClientForm.form_param).permit(CreateCtcClientForm.permitted_params)
    end

    def update_client_form_params
      params.require(UpdateCtcClientForm.form_param).permit(UpdateCtcClientForm.permitted_params)
    end
  end
end