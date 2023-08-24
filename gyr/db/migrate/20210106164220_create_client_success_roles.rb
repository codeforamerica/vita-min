class CreateClientSuccessRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :client_success_roles do |t|
      t.timestamps
    end
  end
end