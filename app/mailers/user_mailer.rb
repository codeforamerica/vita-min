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
    inline_logo
    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: signed_email(@assigned_user.email)
      }
    )

    mail(to: @assigned_user.email, subject: @subject)
  end

  def incoming_interaction_notification_email(client:, user:, received_at:, interaction_count:, interaction_type:)
    @client_id = client.id
    @user = user
    @received_at = received_at.in_time_zone(@user.timezone)
    @interaction_count = interaction_count
    @subject = if interaction_type == "new_client_message"
                 "#{@interaction_count} New Message(s) from GetYourRefund Client ##{@client_id}"
               elsif interaction_type == "document_upload"
                 "#{@interaction_count} New Document(s) Uploaded by GetYourRefund Client ##{@client_id}"
               end
    inline_logo
    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: signed_email(@user.email)
      }
    )

    mail(to: @user.email, subject: @subject, template_name: "#{interaction_type}_notification_email")
  end

  def internal_interaction_notification_email(user:, interaction_type:)
    @user = user
    inline_logo
    @subject = "You were tagged in a note"
    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: signed_email(@user.email)
      }
    )

    mail(to: @user.email, subject: @subject, template_name: "#{interaction_type}_notification_email")
  end

  private

  def inline_logo
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo
  end

  def signed_email(email)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    verifier.generate(email)
  end
end
