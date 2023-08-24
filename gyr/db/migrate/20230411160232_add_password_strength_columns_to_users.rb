class AddPasswordStrengthColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :high_quality_password_as_of, :datetime, default: nil
    add_column :users, :should_enforce_strong_password, :boolean, default: false, null: false
  end
end
