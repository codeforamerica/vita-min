class AddIsClientSupportToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_client_support, :boolean
  end
end
