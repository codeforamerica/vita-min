class AddClientIdToEmailAccessToken < ActiveRecord::Migration[6.0]
  def change
    add_reference :email_access_tokens, :client
    add_reference :text_message_access_tokens, :client
  end
end
