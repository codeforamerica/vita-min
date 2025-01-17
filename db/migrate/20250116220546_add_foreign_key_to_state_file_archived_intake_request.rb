class AddForeignKeyToStateFileArchivedIntakeRequest < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    remove_foreign_key :state_file_archived_intake_requests, :state_file_archived_intakes
    safety_assured { remove_column :state_file_archived_intake_requests, :state_file_archived_intakes_id }
    add_reference :state_file_archived_intake_requests, :state_file_archived_intake, index: {algorithm: :concurrently}
  end
end
