class AddIndexOnEfileSubmissionsIrsSubmissionId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :efile_submissions, :irs_submission_id
  end
end
