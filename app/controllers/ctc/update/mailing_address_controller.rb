class Ctc::Update::MailingAddressController < Ctc::Update::BaseIntakeRevisionController
  def edit_template
    "ctc/portal/mailing_address/edit"
  end

  def edit
    @show_usps_error = true unless current_intake.usps_address_verified_at
    super
  end

  def update
    current_intake.update(usps_address_late_verification_attempts: current_intake.usps_address_late_verification_attempts + 1)
    super
  end

  def form_class
    Ctc::MailingAddressForm
  end
end
