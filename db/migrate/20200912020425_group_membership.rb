class GroupMembership < ActiveRecord::Migration[6.0]
  def change
    create_table :group_memberships do |t|
      t.timestamps
      t.references :added_by, index: true, foreign_key: {to_table: :users}
      t.references :group, null: false
      t.references :user, null: false
    end
  end
end
