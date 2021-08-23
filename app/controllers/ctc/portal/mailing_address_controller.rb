class Ctc::Portal::MailingAddressController < Ctc::Portal::BaseIntakeRevisionController
  private

  def form_class
    Ctc::MailingAddressForm
  end
end
