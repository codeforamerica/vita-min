class AddPermanentlyLockedAtToStateFileArchivedIntakeRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intake_requests, :permanently_locked_at, :datetime
  end
end
