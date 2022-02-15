class AddIdentityVerifiedAtToClient < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :identity_verified_at, :timestamp
  end
end
