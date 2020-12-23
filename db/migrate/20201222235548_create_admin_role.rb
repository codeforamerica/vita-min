class CreateAdminRole < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_roles do |t|
      t.timestamps
    end
  end
end
