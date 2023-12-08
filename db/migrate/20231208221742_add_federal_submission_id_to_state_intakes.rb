class AddFederalSubmissionIdToStateIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :federal_submission_id, :string
    add_column :state_file_az_intakes, :federal_return_status, :string
    add_column :state_file_ny_intakes, :federal_submission_id, :string
    add_column :state_file_ny_intakes, :federal_return_status, :string
  end
end
