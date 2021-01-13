class TaxReturnsController < ApplicationController
  before_action :block_access_on_production, only: [:authorize_signature, :sign, :success]
  before_action :load_tax_return, except: [:success]
  before_action :check_for_forms, only: [:sign, :authorize_signature]

  def authorize_signature
    @primary_signer = true
    @form = Portal::SignForm8879.new(@tax_return)
  end

  def spouse_authorize_signature
    @primary_signer = false
    @form = Portal::SignForm8879.new(@tax_return)

    render :authorize_signature
  end

  def sign
    @form = Portal::SignForm8879.new(@tax_return, permitted_params)
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
    @tax_return = TaxReturn.find(params[:tax_return_id])
  end

  def permitted_params
    params
      .require(Portal::SignForm8879.form_param)
      .permit(:primary_accepts_terms, :primary_confirms_identity)
      .merge(ip: request.remote_ip)
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