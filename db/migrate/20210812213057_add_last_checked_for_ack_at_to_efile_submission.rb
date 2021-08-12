class AddLastCheckedForAckAtToEfileSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_submissions, :last_checked_for_ack_at, :timestamp
  end
end
