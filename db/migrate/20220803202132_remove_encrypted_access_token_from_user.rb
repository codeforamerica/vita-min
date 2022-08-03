class RemoveEncryptedAccessTokenFromUser < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :users, :encrypted_access_token_iv, :string
      remove_column :users, :encrypted_access_token, :string
    end
  end
end
