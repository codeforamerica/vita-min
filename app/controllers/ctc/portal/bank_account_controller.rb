class Ctc::Portal::BankAccountController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    # Deliberately present the form a blank bank account so as to not leak sensitive details
    @form = form_class.from_bank_account(BankAccount.new)
    render edit_template
  end

  private

  def edit_template
    "ctc/portal/bank_account/edit"
  end

  def form_class
    Ctc::BankAccountForm
  end

  def current_model
    @_current_model ||= current_intake.bank_account
  end
  helper_method :current_model
end
