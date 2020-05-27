class RenameUsersToIdmeUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table :users, :idme_users
  end
end
