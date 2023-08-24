class Ctc::Portal::MailingAddressController < Ctc::Portal::BaseIntakeRevisionController
  private

  def edit_template
    "ctc/portal/mailing_address/edit"
  end

  def form_class
    Ctc::MailingAddressForm
  end
end
