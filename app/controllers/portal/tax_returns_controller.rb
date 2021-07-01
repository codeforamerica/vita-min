module Portal
  class TaxReturnsController < PortalController
    before_action :load_client_tax_return, except: [:success]
    before_action :redirect_unless_spouse_signature_required, only: [:spouse_sign, :spouse_authorize_signature]
    before_action :redirect_unless_primary_signature_required, only: [:sign, :authorize_signature]
    layout "application"

    def authorize_signature
      @form = Portal::PrimarySignForm8879.new(@tax_return)
    end

    def spouse_authorize_signature
      @form = Portal::SpouseSignForm8879.new(@tax_return)
    end

    def sign
      form_class = Portal::PrimarySignForm8879
      @form = form_class.new(@tax_return, permitted_params(form_class))
      if @form.sign
        redirect_to portal_tax_return_show_path(tax_return_id: @tax_return.id)
      else
        flash.now[:alert] = I18n.t("controllers.tax_returns_controller.errors.#{@form.errors.keys.first}")
        render :authorize_signature
      end
    end

    def spouse_sign
      form_class = Portal::SpouseSignForm8879
      @form = form_class.new(@tax_return, permitted_params(form_class))
      if @form.sign
        redirect_to portal_tax_return_show_path(tax_return_id: @tax_return.id)
      else
        flash.now[:alert] = I18n.t("controllers.tax_returns_controller.errors.#{@form.errors.keys.first}")
        render :spouse_authorize_signature
      end
    end

    def success; end

    def show; end

    private

    def load_client_tax_return
      @tax_return = current_client.tax_returns.includes(client: [:intake]).find_by(id: params[:tax_return_id])

      return render "public_pages/page_not_found", status: 404 unless @tax_return.present?
    end

    def permitted_params(form_class)
      params
        .require(form_class.form_param)
        .permit(*form_class.permitted_params)
        .merge(ip: request.remote_ip)
    end

    def redirect_unless_signature_required(signature_type)
      unless @tax_return.ready_for_8879_signature?(signature_type)
        flash[:notice] = I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
        redirect_to :portal_root
      end
    end

    def redirect_unless_primary_signature_required
      redirect_unless_signature_required(TaxReturn::PRIMARY_SIGNATURE)
    end

    def redirect_unless_spouse_signature_required
      redirect_unless_signature_required(TaxReturn::SPOUSE_SIGNATURE)
    end
  end
end
