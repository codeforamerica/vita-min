module Hub
  class ZipCodesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource :vita_partner_zip_code
    authorize_resource :vita_partner, parent: false, only: :create

    def create
      vita_partner = VitaPartner.find(params[:vita_partner_id])
      @form = ZipCodeRoutingForm.new(vita_partner, permitted_params)
      if @form.valid?
        @form.save!
        @success_message = I18n.t("hub.zip_codes.success", code: @form.zip_code, name: vita_partner.name)
      else
        flash.now[:alert] = @form.error_summary
      end
      respond_to do |format|
        format.js
      end
    end

    def destroy
      @zip_code_routing = VitaPartnerZipCode.find(params[:id])
      
      @zip_code_routing.destroy!

      respond_to do |format|
        format.js
      end
    end

    def form_class
      ZipCodeRoutingForm
    end

    def permitted_params
      params.require(form_class.form_param).permit(:zip_code)
    end
  end
end