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

  def incoming_interaction_notification_email(client:, user:, received_at:, interaction_count:)
    @client_id = client.id
    @user = user
    @received_at = received_at.in_time_zone(@user.timezone)
    @msg_count = interaction_count
    @subject = @msg_count > 1 ? "#{@msg_count} New Messages from GetYourRefund Client ##{@client_id}" : "New Message from GetYourRefund Client ##{@client_id}"
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo

    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    signed_email = verifier.generate(@user.email)
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
      mail(to: @user.email, subject: @subject)
  end

end
