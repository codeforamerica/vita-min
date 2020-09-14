class CreateGroupAssignment < ActiveRecord::Migration[6.0]
  def change
    create_table :group_assignments do |t|
      t.timestamps
      t.references :assigned_by, index: true, foreign_key: {to_table: :users}
      t.references :group, null: false
      t.references :client, null: false
    end
  end
end
