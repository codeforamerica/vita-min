class LoginLinkInsertionService
  class << self
    def insert_links(contact_record)
      e_signature_link_pattern = /<<\s*link\.e-signature\s*>>/i

      return contact_record.body unless e_signature_link_pattern.match?(contact_record.body)

      login_link = Rails.application.routes.url_helpers.new_portal_client_login_url(locale: contact_record.client.intake.locale)
      contact_record.body.gsub(e_signature_link_pattern, login_link)
    end
  end
end
