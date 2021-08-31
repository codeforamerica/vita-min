class Ctc::Update::MailingAddressController < Ctc::Update::BaseIntakeRevisionController
  def edit_template
    "ctc/portal/mailing_address/edit"
  end

  def form_class
    Ctc::MailingAddressForm
  end
end
