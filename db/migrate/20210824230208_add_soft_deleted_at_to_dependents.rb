class AddSoftDeletedAtToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :soft_deleted_at, :datetime
  end
end
