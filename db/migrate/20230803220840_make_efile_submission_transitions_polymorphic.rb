class MakeEfileSubmissionTransitionsPolymorphic < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :efile_submission_transitions, :efile_submissions
    add_column :efile_submission_transitions, :efile_submission_type, :string, null: false, default: 'EfileSubmission'
  end
end
