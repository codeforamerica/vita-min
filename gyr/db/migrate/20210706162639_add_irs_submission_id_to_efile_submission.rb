class AddIrsSubmissionIdToEfileSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_submissions, :irs_submission_id, :string
  end
end
