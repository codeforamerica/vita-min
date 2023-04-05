class RenameForcedPasswordResetAt < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :users, :forced_password_reset_at, :high_quality_password_as_of
      add_column :users, :signed_in_after_strong_password_change, :boolean
    end
  end
end
