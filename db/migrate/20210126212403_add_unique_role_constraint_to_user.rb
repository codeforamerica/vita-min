class AddUniqueRoleConstraintToUser < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:users, :role_type, false)
    change_column_null(:users, :role_id, false)
    remove_index(:users, [:role_type, :role_id])
    add_index(:users, [:role_type, :role_id], unique: true)
  end
end
