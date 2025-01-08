# frozen_string_literal: true

class AddDeviseToStateFileArchivedIntakeRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intake_requests, :failed_attempts, :integer,  default: 0, null: false
    add_column :state_file_archived_intake_requests, :locked_at, :datetime
  end
end
