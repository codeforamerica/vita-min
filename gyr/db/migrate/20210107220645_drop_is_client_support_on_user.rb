class DropIsClientSupportOnUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :is_client_support
  end
end
