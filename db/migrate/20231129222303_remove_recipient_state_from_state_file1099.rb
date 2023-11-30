class RemoveRecipientStateFromStateFile1099 < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file1099_gs, :recipient_state, :string }
  end
end
