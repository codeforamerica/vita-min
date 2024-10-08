require "rails_helper"

shared_examples "a mailer with an unsubscribe link" do
  it "includes a signed unsubscribe link" do
    email = described_class.public_send(mail_method, **mailer_args)
    email.deliver_now

    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    signed_email = verifier.generate(email_address)

    unsubscribe_url = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: signed_email
      }
    )

    expect(email.html_part.decoded).to include(unsubscribe_url)
  end
end
