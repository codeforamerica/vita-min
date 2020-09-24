class AddIsBetaTesterToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_beta_tester, :boolean, default: false, null: false
  end
end
