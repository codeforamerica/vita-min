class Ctc::Portal::RefundPaymentController < Ctc::Portal::BaseIntakeRevisionController

  def edit
    @form = form_class.new(current_intake)
    render edit_template
  end

  private

  def next_path
    if current_intake.refund_payment_method_direct_deposit?
      redirect_to ctc_portal_bank_account_path
    elsif current_intake.refund_payment_method_check?
      redirect_to ctc_portal_mailing_address_path
    else
      redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
    end
  end

  def edit_template
    "ctc/portal/refund_payment/edit"
  end

  def form_class
    Ctc::Portal::RefundPaymentForm
  end

  def current_model
    @_current_model ||= current_intake
  end
  helper_method :current_model
end