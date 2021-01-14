class ClientLoginRequestJob < ApplicationJob
  def perform(email_address: nil, phone_number: nil)
    raise ArgumentError.new("No contact info provided") unless email_address.present? || phone_number.present?

    clients = Client.by_contact_info(email_address: email_address, phone_number: phone_number)

    if clients.present?
      raw_token, encrypted_token = Devise.token_generator.generate(Client, :login_token)
      clients.update(
        login_token: encrypted_token,
        login_requested_at: DateTime.now
      )
      client_login_link = Rails.application.routes.url_helpers.edit_portal_client_login_url(id: raw_token)
      ClientLoginRequestMailer.token_link(token_url: client_login_link).deliver_later if email_address.present?
    else
      ClientLoginRequestMailer.no_match_found.deliver_later if email_address.present?
    end
  end
end
