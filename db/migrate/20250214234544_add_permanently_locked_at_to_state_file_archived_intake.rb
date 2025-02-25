class AddPermanentlyLockedAtToStateFileArchivedIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intakes, :permanently_locked_at, :datetime
  end
end
