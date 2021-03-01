class LoginLinkInsertionService
  class << self
    def insert_links(contact_record)
      e_signature_link_pattern = /<<\s*link\.e-signature\s*>>/i

      return contact_record.body unless e_signature_link_pattern.match?(contact_record.body)

      raw_token = if contact_record.is_a?(OutgoingTextMessage)
        ClientLoginsService.issue_text_message_token(contact_record.to_phone_number)
      elsif contact_record.is_a?(OutgoingEmail)
        ClientLoginsService.issue_email_token(contact_record.to)
      end

      login_link = Rails.application.routes.url_helpers.portal_client_login_url(locale: contact_record.client.intake.locale, id: raw_token)
      contact_record.body.gsub(e_signature_link_pattern, login_link)
    end
  end
end
