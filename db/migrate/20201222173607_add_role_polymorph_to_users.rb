class AddRolePolymorphToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :role, polymorphic: true, index: true
  end
end
