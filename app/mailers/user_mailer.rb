class UserMailer < ApplicationMailer
  default from: Rails.configuration.email_from[:noreply][:gyr]

  helper :time

  def assignment_email(
    assigned_user:,
    assigning_user:,
    tax_return:,
    assigned_at:
  )
    @assigned_user = assigned_user
    @assigning_user = assigning_user
    @assigned_at = assigned_at.in_time_zone(@assigned_user.timezone)
    @client = tax_return.client
    @subject = "GetYourRefund Client ##{@client.id} Assigned to You"
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo

    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    signed_email = verifier.generate(@assigned_user.email)

    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: signed_email
      }
    )

    mail(to: @assigned_user.email, subject: @subject)
  end
end
