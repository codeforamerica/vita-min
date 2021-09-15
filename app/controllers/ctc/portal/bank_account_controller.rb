class Ctc::Portal::BankAccountController < Ctc::Portal::BaseIntakeRevisionController

  def edit
    @form = form_class.new(current_intake)
    render edit_template
  end

  private

  def edit_template
    "ctc/portal/bank_account/edit"
  end

  def form_class
    Ctc::Portal::BankAccountForm
  end

  def current_model
    @_current_model ||= current_intake.bank_account
  end
  helper_method :current_model
end
