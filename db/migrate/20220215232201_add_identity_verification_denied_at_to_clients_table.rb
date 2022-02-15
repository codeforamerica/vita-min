class AddIdentityVerificationDeniedAtToClientsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :identity_verification_denied_at, :timestamp
  end
end
