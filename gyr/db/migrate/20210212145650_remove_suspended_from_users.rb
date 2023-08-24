class RemoveSuspendedFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :suspended
  end
end
