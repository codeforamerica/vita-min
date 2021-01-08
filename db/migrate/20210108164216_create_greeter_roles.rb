class CreateGreeterRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :greeter_roles do |t|
      t.references :coalition, null: false, foreign_key: true
      t.references :vita_partner, null: false, foreign_key: true
      t.timestamps
    end
  end
end
