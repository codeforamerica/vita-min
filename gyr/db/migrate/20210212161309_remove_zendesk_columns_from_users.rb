class RemoveZendeskColumnsFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :zendesk_user_id
    remove_column :users, :ticket_restriction
    remove_column :users, :two_factor_auth_enabled
    remove_column :users, :active
    remove_column :users, :verified
  end
end
