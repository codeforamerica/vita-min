class AddOriginalIntakeIdToStateFileArchivedIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intakes, :original_intake_id, :string
  end
end
