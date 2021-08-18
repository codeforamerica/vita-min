class AddCreationTokenToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :creation_token, :string
    add_index :dependents, :creation_token
  end
end
