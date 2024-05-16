module Hub
  class SourceParamsController < Hub::BaseController
    authorize_resource :vita_partner, parent: false, only: :create

    def create
      @vita_partner = VitaPartner.find(params[:vita_partner_id])
      @form = form_class.new(@vita_partner, permitted_params)
      if @form.valid?
        @form.save!
        @success_message = I18n.t("hub.source_params.success", code: @form.code, name: @vita_partner.name)
      else
        flash.now[:alert] = @form.error_summary
      end
      respond_to do |format|
        format.js
      end
    end

    def update
      @source_param = SourceParameter.find(params[:id])
      @source_param.update(active: params[:source_parameter][:active] == "1")
      respond_to do |format|
        format.js
      end
    end

    def destroy
      @source_param = SourceParameter.find(params[:id])

      @source_param.destroy!
      respond_to do |format|
        format.js
      end
    end

    def form_class
      SourceParamsForm
    end

    def permitted_params
      params.require(form_class.form_param).permit(:code)
    end
  end
end
