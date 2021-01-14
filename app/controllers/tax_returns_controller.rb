class TaxReturnsController < ApplicationController
  before_action :block_access_on_production, only: [:authorize_signature, :sign, :success]
  before_action :load_tax_return, except: [:success]
  before_action :redirect_unless_primary_signature_required, only: [:sign, :authorize_signature]
  before_action :redirect_unless_spouse_signature_required, only: [:spouse_sign, :spouse_authorize_signature]

  def authorize_signature
    @primary_signer = true
    @form = Portal::PrimarySignForm8879.new(@tax_return)
  end

  def spouse_authorize_signature
    @primary_signer = false
    @form = Portal::SpouseSignForm8879.new(@tax_return)

    render :authorize_signature
  end

  def sign
    form_class = Portal::PrimarySignForm8879
    @form = form_class.new(@tax_return, permitted_params(form_class))
    if @form.sign
      redirect_to tax_return_success_path(params[:tax_return_id])
    else
      flash.now[:alert] = I18n.t("controllers.tax_returns_controller.errors.#{@form.errors.keys.first}")
      render :authorize_signature
    end
  end

  def spouse_sign
    form_class = Portal::SpouseSignForm8879
    @form = form_class.new(@tax_return, permitted_params(form_class))
    if @form.sign
      redirect_to tax_return_success_path(params[:tax_return_id])
    else
      flash.now[:alert] = I18n.t("controllers.tax_returns_controller.errors.#{@form.errors.keys.first}")
      render :authorize_signature
    end
  end

  def success; end

  private

  def load_tax_return
    @tax_return = TaxReturn.includes(client: [:intake]).find(params[:tax_return_id])
  end

  def permitted_params(form_class)
    params
      .require(form_class.form_param)
      .permit(*form_class.permitted_params)
      .merge(ip: request.remote_ip)
  end

  def redirect_unless_primary_signature_required
    if @tax_return.primary_has_signed?
      flash[:notice] = I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
      return redirect_to :root
    end
    check_for_forms
  end

  def redirect_unless_spouse_signature_required
    if @tax_return.only_needs_primary_signature? || @tax_return.spouse_has_signed?
      flash[:notice] = I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
      return redirect_to :root
    end
    check_for_forms
  end

  def check_for_forms
    if @tax_return.documents.find_by(document_type: DocumentTypes::CompletedForm8879.key).present?
      flash[:notice] = I18n.t("controllers.tax_returns_controller.errors.already_signed")
      return redirect_to :root
    end

    unless @tax_return.documents.find_by(document_type: DocumentTypes::Form8879.key).present?
      flash[:notice] = I18n.t("controllers.tax_returns_controller.errors.not_ready_to_sign")
      return redirect_to :root
    end
  end


  # This is a WIP MVP feature that isn't ready for prime time, but we want to get it onto demo for testing.
  # Let's send anyone trying to access this on prod back to root.
  def block_access_on_production
    return redirect_to :root if Rails.env.production?
  end
end