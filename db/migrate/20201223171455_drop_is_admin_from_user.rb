class DropIsAdminFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :is_admin
  end
end
