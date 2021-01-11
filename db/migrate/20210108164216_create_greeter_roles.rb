class CreateGreeterRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :greeter_roles do |t|
      t.timestamps
    end
    create_table :greeter_organization_join_records do |t|
      t.references :greeter_role, null: false, foreign_key: true
      t.references :vita_partner, null: false, foreign_key: true
      t.timestamps
    end
    create_table :greeter_coalition_join_records do |t|
      t.references :greeter_role, null: false, foreign_key: true
      t.references :coalition, null: false, foreign_key: true
      t.timestamps
    end
  end
end
