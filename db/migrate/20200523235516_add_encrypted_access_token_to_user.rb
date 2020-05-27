class AddEncryptedAccessTokenToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      add_column :users, :encrypted_access_token, :string
      add_column :users, :encrypted_access_token_iv, :string
    end
  end
end
