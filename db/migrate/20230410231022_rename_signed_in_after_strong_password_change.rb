class RenameSignedInAfterStrongPasswordChange < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :users, :signed_in_after_strong_password_change, :should_enforce_strong_password
    end
  end
end
