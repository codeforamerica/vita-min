class AddForcedPasswordResetToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :forced_password_reset_at, :datetime, default: nil
  end
end
