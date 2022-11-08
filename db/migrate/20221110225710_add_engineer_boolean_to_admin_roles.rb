class AddEngineerBooleanToAdminRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_roles, :engineer, :boolean
  end
end
