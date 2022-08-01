class DropUnusedColumnFromUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :encrypted_access_token, :string
    remove_column :users, :encrypted_access_token_iv, :string
  end
end
