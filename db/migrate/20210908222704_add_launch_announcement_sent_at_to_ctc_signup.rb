class AddLaunchAnnouncementSentAtToCtcSignup < ActiveRecord::Migration[6.0]
  def change
    add_column :ctc_signups, :launch_announcement_sent_at, :datetime
  end
end
