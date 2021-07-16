class AddMiddleInitialToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :middle_initial, :string
  end
end
