class AddStateFileFlagToAdminRole < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_roles, :state_file, :boolean, default: false, null: false
  end
end
