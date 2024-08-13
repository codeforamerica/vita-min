class AddFederalSubmissionIdToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :federal_submission_id, :string
    add_column :state_file_nc_intakes, :federal_return_status, :string
  end
end
