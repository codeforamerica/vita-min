class AddMessageTrackerToEfileSubmission < ActiveRecord::Migration[7.1]
  def change
    add_column :efile_submissions, :message_tracker, :jsonb, default: {}
  end
end
