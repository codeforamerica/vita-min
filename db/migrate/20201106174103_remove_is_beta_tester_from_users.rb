class RemoveIsBetaTesterFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :is_beta_tester
  end
end
